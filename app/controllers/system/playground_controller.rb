class System::PlaygroundController < ApplicationController
  require "open3"
  include Exports

  before_action :change_db
  after_action  :restore_db

  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"

  def search_01
    # 初期検索クエリ作成
    @products = Product.status(Product::STATUS[:mix])
      .where("products.created_at <= ?", Date.new(2020, 7, 3).to_time)
      .includes(:product_images, :category, :user)
      .order(id: :desc)


    if params[:product_id]
      ### 似たものサーチ ###
      @time = Benchmark.realtime do
        @target = Product.find(params[:product_id])
        @sorts = sort_by_vector(@target, @products)
        @products = @products.where(id: @sorts.keys).sort_by { |pr| @sorts[pr.id] }
      end
    else
      ### 通常サーチ ###
      ### 検索キーワード ###
      @keywords = params[:keywords].to_s

      # 初期検索クエリ作成
      @products = @products.with_keywords(@keywords)

      # カテゴリ
      if params[:category_id].present?
        @category = Category.find(params[:category_id])
        @products = @products.search(category_id_in: @category.subtree_ids).result
      end

      ### ページャ ###
      @pproducts = @products.page(params[:page])
    end

    ### 検索セレクタ ###
    @categories_selector = Category.options

    respond_to do |format|
      format.html
      format.csv { export_csv "products_images.csv" }
    end
  end

  ### ベクトル一括変換 ###
  def vector_maker
    ### データを取得 ###
    @products = Product.status(Product::STATUS[:mix]).includes(:product_images).all.order(:id)

    @products.each do |pr|
      next if pr.product_images.first.blank?
      filename = pr.product_images.first.image_identifier
      logger.debug "[[[ #{filename} ]]]"

      ### ファイルの存否を確認 ###
      next if File.exist? "#{VECTORS_PATH}/vector_#{pr.id}.npy"

      cmds = []

      ### S3より画像ファイルの取得 ###
      unless File.exist? "#{UTILS_PATH}/static/img/#{filename}"
        # cmds << "aws s3 cp s3://development.auction/uploads/product_image/image/#{pr.id}/#{filename} #{UTILS_PATH}/static/img/;"
        # cmds << "wget #{pr.product_images.first.image.url} -P #{UTILS_PATH}/static/img/;"
        cmds << "wget #{img_base}/#{pr.product_images.first.id}/#{pr.product_images.first.image_identifier} -P #{UTILS_PATH}/static/img/;"
      end

      next unless File.exist? "#{UTILS_PATH}/static/img/#{filename}"

      ### プロセス ###
      cmds << "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{UTILS_PATH}/static/img/#{filename}\";"

      cmds << "mv #{VECTORS_PATH}/#{filename}.npy #{VECTORS_PATH}/vector_#{pr.id}.npy"
      cmds << "rm #{UTILS_PATH}/static/img/#{filename}"

      exec_commands(cmds)
    end

    redirect_to "/system/playground/search_01", notice: "変換完了"
  end

  private

  def exec_commands(commands)
    commands.each do |cmd|
      logger.debug cmd
      o, e, s = Open3.capture3(cmd)
      logger.debug o
      logger.debug e
      logger.debug s

    end
  end

  def sort_by_vector(target, products)
    pids = products.pluck(:id).uniq

    if params[:type] == "redis" # Narrayでnorm計算 + Redisでキャッシュ
      ### 結果キャッシュ ###
      Rails.cache.fetch("sort_result_#{target.id}") do
        vectors = Rails.cache.read("vectors") || {}

        if vectors.blank?
          pids.each do |pid|
            vectors[pid] ||= if File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"
              Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
            else
              nil
            end
          end

          Rails.cache.write("vectors", vectors)
        end

        ### targetのベクトル取得 ###
        target_narray = vectors[target.id]

        ### 各ベクトル比較 ###
        pids.map do |pid|
          if pid == target.id || vectors[pid].blank?
            nil
          else
            sub_nayyar = vectors[pid] - target_narray
            res        = (sub_nayyar * sub_nayyar).sum

            [pid, res]
          end
        end.compact.sort_by { |v| v[1] }.first(30).to_h
      end

    else
      ### targetのベクトル取得 ###
      if File.exist? "#{VECTORS_PATH}/vector_#{target.id}.npy"
        target_narray = Npy.load("#{VECTORS_PATH}/vector_#{target.id}.npy")
        target_vector = Vector.elements(target_narray.to_a)
      end

      ### 各ベクトル比較 ###
      sorts = pids.map do |pid|
        ### ファイルの存否を確認 ###
        if pid == target.id # ターゲットを除外
          nil
        elsif File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"
          pr_narray = Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")

          ### ベクトル取得 ###
          res = case params[:type]
          when "angle" # 角度計算
            pr_vector = Vector.elements(pr_narray.to_a)
            target_vector.angle_with(pr_vector)
          when "norm" # norm計算
            pr_vector = Vector.elements(pr_narray.to_a)
            (target_vector - pr_vector).r
          else # Narrayでnorm計算
            sub_nayyar = pr_narray - target_narray
            (sub_nayyar * sub_nayyar).sum
          end

          logger.debug "[[ #{pid}, #{res} ]]"
          [pid, res]
        else
          nil
        end
      end.compact.sort_by { |v| v[1] }.first(30).to_h
    end

  end

  def change_db
    Thread.current[:request] = request

    case Rails.env
    when "production"; redirect_to "/"
    when "staging"
      ActiveRecord::Base.establish_connection(:production)
      @img_base   = "https://s3-ap-northeast-1.amazonaws.com/mnok/uploads/product_image/image"
      @link_base = "https://www.mnok.net/"
    else
      @img_base  = "https://s3-ap-northeast-1.amazonaws.com/development.auction/uploads/product_image/image"
      @link_base = "http://192.168.33.110:8087/"
    end
  end

  def restore_db
    if Rails.env == "staging"
      ActiveRecord::Base.establish_connection(:staging)
    end
  end
end
