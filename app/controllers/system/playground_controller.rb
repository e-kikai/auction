class System::PlaygroundController < ApplicationController
  require "open3"
  include Exports

  before_action :change_db
  after_action  :restore_db

  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"

  def search_01
    ### 検索キーワード ###
    @keywords = params[:keywords].to_s

    # 初期検索クエリ作成
    # @search = Product.status(Product::STATUS[:start]).with_keywords(@keywords).search(params[:q])
    @products = Product.status(Product::STATUS[:mix]).with_keywords(@keywords).where("products.created_at <= ?", Date.new(2020, 7, 3).to_time)

    # カテゴリ
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @products = @products.search(category_id_in: @category.subtree_ids).result
    end

    @products  = @products.includes(:product_images, :category, :user).order(id: :desc)

    ### 画像ベクトルソート処理 ###
    if params[:product_id]
      @time = Benchmark.realtime do
        @target = Product.find(params[:product_id])
        @sorts = sort_by_vector(@target, @products)
        @products = @products.where(id: @sorts.keys).sort_by { |pr| @sorts[pr.id] }
      end
    else
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
    ### targetのベクトル取得 ###
    if  File.exist? "#{VECTORS_PATH}/vector_#{target.id}.npy"
      tmp = Npy.load("#{VECTORS_PATH}/vector_#{target.id}.npy")
      target_vector = Vector.elements(tmp.to_a)
    else

    end

    # dummy #
    # target_vector = Rails.cache.fetch("/Products/#{target.id}/vector") do
    #   target_array  = 4096.times.map { |a| rand(0.0..1.0) }
    #   Vector.elements(target_array)
    # end
    # target_array  = 4096.times.map { |a| rand(0.0..1.0) }
    # target_vector = Vector.elements(target_array)

    pids = products.pluck(:id).uniq

    sorts = pids.map do |pid|
      ### ファイルの存否を確認 ###
      if pid == target.id # ターゲットを除外
        nil
      elsif File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"

        ### ベクトル取得 ###
        # dummy #
        # pr_vector = Rails.cache.fetch("/Products/#{pr.id}/vector") do
        #   atmp      = 4096.times.map { |a| rand(0.0..1.0) }
        #   Vector.elements(atmp)
        # end
        tmp       = Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
        pr_vector = Vector.elements(tmp.to_a)

        # atmp      = 4096.times.map { |a| rand(0.0..1.0) }
        # pr_vector = Vector.elements(atmp)

        res = case params[:type]
        when "angle" # 角度計算
          target_vector.angle_with(pr_vector)
        else # norm計算
          (target_vector - pr_vector).r
        end

        logger.debug "[[ #{pid}, #{res} ]]"
        [pid, res]
      else
        # [pid, 2048.0]
        nil
      end

    end.compact.sort_by { |v| v[1] }.first(30).to_h

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
