class System::PlaygroundController < ApplicationController
  require "open3"
  include Exports

  before_action :change_db
  after_action  :restore_db

  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"

  ZERO_NARRAY  =  Numo::SFloat.zeros(1)

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

      cmds << "mv #{VECTORS_PATH}/#{filename}.npy #{VECTORS_PATH}/vector_#{pr.id}.npy" # ファイル移動
      cmds << "rm #{UTILS_PATH}/static/img/#{filename}" # 画像ファイル削除

      exec_commands(cmds)
    end

    redirect_to "/system/playground/search_01", notice: "変換完了"
  end

  ### ベクトル変換処理 ###
  def vector_maker_solo
    @time = Benchmark.realtime do
      ### 初期化 ###
      resource = Aws::S3::Resource.new(
        access_key_id:     Rails.application.secrets.aws_access_key_id,
        secret_access_key: Rails.application.secrets.aws_secret_access_key,
        region:            'ap-northeast-1', # Tokyo
      )

      bucket = resource.bucket(@bucket_name)

      logger.debug "*** 1 : #{@bucket_name}"

      ### ターゲット商品情報取得 ###
      product = Product.find(params[:id])

      vector_key  = "vectors/vector_#{product.id}.npy"

      if product.product_images.first.blank?
        ### 画像の有無チェック ###
        redirect_to "/system/playground/search_01", alert: "商品に画像が登録されていません" and return
      elsif bucket.object(vector_key).exists?
        ### ベクトルファイルの存否を確認 ###
        redirect_to "/system/playground/search_01", alert: "ベクトルファイルがすでに存在します" and return
      end
      logger.debug "*** 2 : #{vector_key}"

      ### S3より画像ファイルの取得 ###
      @filename    = product.product_images.first.image_identifier
      image_id    = product.product_images.first.id
      image_key   = "uploads/product_image/image/#{image_id}/#{@filename}"

      image_path  = "#{UTILS_PATH}/static/img/#{@filename}"
      vector_path = "#{VECTORS_PATH}/#{@filename}.npy"

      logger.debug "*** 3 : #{image_key}"

      bucket.object(image_key).get(response_target: "#{image_path}")

      logger.debug "*** 4 : #{image_path}"

      ### プロセス ###
      cmds = []
      cmds << "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{image_path}\";"
      exec_commands(cmds)

      logger.debug "*** 5 : #{vector_path}"

      ### ベクトルファイルアップロード ###
      bucket.object(vector_key).upload_file(vector_path)

      logger.debug "*** 6 : upload"


      ### 不要になった画像ファイル、ベクトルファイルの削除
      File.delete(vector_path)
      File.delete(image_path)

      logger.debug "*** 7 : delete"
    end

    ### ベクトルキャッシュ更新 ###
    # update_vector

    redirect_to "/system/playground/search_01", notice: "ベクトル変換完了 : #{@filename} : #{@time}"
  # rescue => e
  #   redirect_to "/system/playground/search_01", alert: "ベクトル変換エラー : #{e.message}"
  end

  ### VBPRテスト用データ ###
  def vbpr_list
    @watches = Watch.all.pluck(:user_id, :product_id)
    @bids    = Bid.all.pluck(:user_id, :product_id)

    @lists = (@watches + @bids).uniq

    respond_to do |format|
      format.csv {
        export_csv "vbpr_list.csv"
      }
    end
  end

  ### BPRテスト用データ(バイアスあり) ###
  def bpr_list_02
    @watches     = Watch.distinct.pluck(:user_id, :product_id)
    @bids        = Bid.distinct.pluck(:user_id, :product_id)
    @detail_logs = DetailLog.distinct.where.not(user_id: nil).pluck(:user_id, :product_id)

    @lists = {}
    @detail_logs.each do |lo|
      @lists[[lo[0], lo[1]]] = 1
    end

    @watches.each do |wa|
      @lists[[wa[0], wa[1]]] = (@lists[[wa[0], wa[1]]] || 0) + 4
    end

    @bids.each do |bi|
      @lists[[bi[0], bi[1]]] = (@lists[[bi[0], bi[1]]] || 0) + 10
    end

    respond_to do |format|
      format.csv {
        export_csv "bpr_list_02.csv"
      }
    end
  end

  ### 現在出品されている商品のIDリストCSV ###
  def bpr_now_products
    @products_ids = Product.status(Product::STATUS[:start])
      .where(id: DetailLog.distinct.select(:product_id).where.not(user_id: nil))
      .pluck(:id)

    respond_to do |format|
      format.csv {
        export_csv "bpr_now_products.csv"
      }
    end
  end

  ### VBPR処理テスト ###
  def vbpr_test
    ### ログのあるを取得 ###
    img_ids      = ProductImage.distinct.select(:product_id)
    products     = Product.all # 削除されたものを除外
    @watches     = Watch.distinct.where(product_id: img_ids).where(product_id: products, created_at: DetailLog::VBPR_RANGE).pluck(:user_id, :product_id)
    @bids        = Bid.distinct.where(product_id: img_ids).where(product_id: products, created_at: DetailLog::VBPR_RANGE).pluck(:user_id, :product_id)
    @detail_logs = DetailLog.distinct.where.not(user_id: nil).where(product_id: img_ids, created_at: DetailLog::VBPR_RANGE).where(product_id: products).pluck(:user_id, :product_id)

    ### 現在出品中の商品(画像あり)を取得 ###
    @now_products = Product.status(Product::STATUS[:start]).where(id: img_ids).pluck(:id)

    ### バイアスを集計 ###
    @biases = @detail_logs.map { |lo| [[lo[0], lo[1]] , DetailLog::VBPR_BIAS[:detail]] }.to_h
    @watches.each { |wa| @biases[[wa[0], wa[1]]] = (@biases[[wa[0], wa[1]]] || 0) + DetailLog::VBPR_BIAS[:watch] }
    @bids.each    { |bi| @biases[[bi[0], bi[1]]] = (@biases[[bi[0], bi[1]]] || 0) + DetailLog::VBPR_BIAS[:bid] }

    ### スパース行列に変換 ###
    user, product, bias = [], [], []

    @biases.each do |key, val|
      user    << key[0].to_i
      product << key[1].to_i
      bias    << val || 1
    end

    user_idx = user.uniq.map.with_index { |v, i| [v, i] }.to_h # ユーザインデックスhash
    user_key = user.map { |v| user_idx[v] } # ユーザインデックスに変換

    product_idx = product.uniq.map.with_index { |v, i| [v, i] }.to_h # 商品インデックスhash
    product_key = product.map { |v| product_idx[v] } # 商品インデックスに変換

    ### 現在出品中の商品のみインデックスhash ###
    now_product_idx = @now_products.map { |pid| [ pid, product_idx[pid] ] }.to_h

    ### 現在出品中、かつ、ログのない商品をインデックスに追加 ###
    plus_products_idx = (@now_products - product.uniq).map.with_index { |v, i| [v, (i + product.uniq.length)] }.to_h
    product_idx.merge! plus_products_idx

    res = {
      user_idx:    user_idx,
      user_key:    user_key,
      product_idx: product_idx,
      product_key: product_key,
      bias:        bias,

      now_product_idx:   now_product_idx,
      plus_products_idx: plus_products_idx,

      # 設定類
      config: {
        # bucket_name: Rails.application.secrets.aws_s3_bucket,
        bucket_name: @bucket_name,
        vbpr_csv_file: DetailLog::VBPR_CSV_FILE,
        bpr_csv_file:  DetailLog::BPR_CSV_FILE,
        npz_file:      DetailLog::VBPR_NPZ_FILE,
        tempfile:      DetailLog::VBPR_TEMP,
        limit:         DetailLog::VBPR_LIMIT,
        epochs:        DetailLog::VBPR_EPOCHS,
      }
    }.to_json

    respond_to do |format|
      format.json { render plain: res }
    end
  end

  ### VBPR表示テスト ###
  def vbpr_view
    ### ユーザセレクタ ###
    detail_logs   = DetailLog.where(created_at: DetailLog::VBPR_RANGE)
    @detail_count = detail_logs.group(:user_id).order("count_all DESC").count
    @watch_cont   = Watch.where(created_at: DetailLog::VBPR_RANGE).group(:user_id).count
    @bid_count    = Bid.where(created_at: DetailLog::VBPR_RANGE).group(:user_id).count

    @user_selector = User.where(id: detail_logs.select(:user_id)).order(:id)
      .map { |us| ["#{us.id} : #{us.company} #{us.name} (#{@bid_count[us.id].to_i} / #{@watch_cont[us.id].to_i} / #{@detail_count[us.id].to_i})", us.id] }

    ### 初期設定 ###
    limit          = 10
    products       = Product.includes(:product_images).limit(limit)
    start_products = products.status(Product::STATUS[:start])

    if params[:user_id]
      ### VBPR結果取得 ###
      @vbpr_products = DetailLog.vbpr_get(params[:user_id], limit)

      ### BPR結果取得 ###
      @bpr_products  = DetailLog.vbpr_get(params[:user_id], limit, true)

      ### 履歴他 ###
      # detaillog_pids = DetailLog.where(user_id: params[:user_id], created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      # @detaillog_products = products.where(id: detaillog_pids)

      watch_pids      = Watch.where(user_id: params[:user_id], created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      @watch_products = products.where(id: watch_pids)

      bid_pids        = Bid.where(user_id: params[:user_id], created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      @bid_products   = products.where(id: bid_pids)

      ### 入札してみませんか ###
      cart_log_pids  = DetailLog.where(user_id: params[:user_id]).select(:product_id).group(:product_id).order("count(product_id) DESC").limit(limit)
      watch_pids     = Watch.where(user_id: params[:user_id], created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      @cart_products = start_products
        .where(id: watch_pids)
        .or(start_products.where(id: cart_log_pids))
        .where.not(id: bid_pids).reorder("random()")

      ### 最近チェックした商品 ###
      # detaillog_pids = DetailLog.group(:product_id).where(user_id: params[:user_id])
      #   .order("max(created_at) DESC").limit(limit)
      #   .pluck(:product_id)


      # @detaillog_products = products.where(id: detaillog_pids).sort_by{ |pr| detaillog_pids.index(pr.id)}
      # @detaillog_pids =  detaillog_pids
      # @detaillog_names = products.where(id: detaillog_pids).pluck(:name)

      @detaillog_products = products.joins(:detail_logs).group(:id).where(user_id: params[:user_id]).reorder("max(detail_logs.created_at)")


      # ### 入札履歴からのオススメ ###
      # bids_pids = Bid.where(user_id: params[:user_id]).select(:product_id).order(id: :desc).limit(limit)
      # @bids_key = products.where(id: bids_pids)

    else
      ### 最近チェックした商品 for IP ###
      detaillog_pids = DetailLog.group(:product_id).where(ip: ip)
      .order("max(created_at) DESC").limit(limit)
      .pluck(:product_id)

      @ip = ip
      # @detaillog_products = products.where(id: detaillog_pids).sort_by{ |pr| detaillog_pids.index(pr.id)}

      @detaillog_products = products.joins(:detail_logs).group(:id).where(ip: ip).reorder("max(detail_logs.created_at)")
    end

    ### ユーザ共通 : 現在出品中の商品からのみ取得 ###
    @end_products   = start_products.reorder(:dulation_end) # まもなく終了

    news            = start_products.reorder(dulation_start: :desc)
    @tool_news      = news.where(category_id: Category.find(1).subtree_ids) rescue [] # 機械新着
    @machine_news   = news.where(category_id: Category.find(107).subtree_ids) rescue [] # 工具新着

    @zero_products  = start_products.joins(:detail_logs).group(:id).reorder("count(detail_logs.id), random()") # 閲覧少
  end

  private

  ### キャッシュ更新 ###
  def update_vector(rehash=false)
    pids = Product.status(Product::STATUS[:mix]).order(:id).pluck(:id).uniq

    vectors = if rehash
      {}
    else
      Rails.cache.read("vectors") || {}
    end

    update_flag = false
    pids.each do |pid|
      ### ベクトルの確認 ###
      if vectors[pid].blank? && File.exist?("#{VECTORS_PATH}/vector_#{pid}.npy")
        update_flag  = true # 更新あり
        vectors[pid] = Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
      end
    end

    ### ベクトルキャシュ更新 ###
    Rails.cache.write("vectors", vectors) if update_flag == true
  end

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

    if params[:type] == "redis" # Narrayでnorm計算 + キャッシュ
      ### 結果キャッシュ ###
      Rails.cache.fetch("sort_result_#{target.id}", expired_in: 3.hour) do
        vectors     = Rails.cache.read("vectors") || {}
        update_flag = false

        ### targetのベクトル取得 ###
        target_narray = if vectors[target.id].present?
          vectors[target.id]
        elsif File.exist? "#{VECTORS_PATH}/vector_#{target.id}.npy"
          update_flag = true
          Npy.load("#{VECTORS_PATH}/vector_#{target.id}.npy")
        end

        if vectors.blank?
          pids.each do |pid|
            vectors[pid] ||= if File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"
              Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
            else
              nil
            end
          end
        end

        ### 各ベクトル比較 ###
        sorts = pids.map do |pid|
          ### ベクトルの取得 ###
          pr_narray = if vectors[pid].present? # 既存
            vectors[pid]
          else # 新規
            update_flag = true
            vectors[pid] = if File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"
              Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
            else
              ZERO_NARRAY
            end
            vectors[pid]
          end

          ### ベクトル比較 ###
          if pid == target.id || pr_narray == ZERO_NARRAY # ベクトルなし
            nil
          else # ノルム比較
            sub_nayyar = pr_narray - target_narray
            res        = (sub_nayyar * sub_nayyar).sum
            [pid, res]
          end

        end.compact.sort_by { |v| v[1] }.first(30).to_h

        ### ベクトルキャシュ更新 ###
        Rails.cache.write("vectors", vectors) if update_flag == true

        sorts
      end

    elsif params[:type] == "solo_cache" # Narrayでnorm計算 + 個別キャッシュ

      ### targetのベクトル取得 ###
      if File.exist? "#{VECTORS_PATH}/vector_#{target.id}.npy"
        target_narray = Rails.cache.fetch("sort_result_#{target.id}") do
          Npy.load("#{VECTORS_PATH}/vector_#{target.id}.npy")
        end
      end

      ### 各ベクトル比較 ###
      sorts = pids.map do |pid|
        ### ファイルの存否を確認 ###
        if pid == target.id # ターゲットを除外
          nil
        elsif File.exist? "#{VECTORS_PATH}/vector_#{pid}.npy"
          pr_narray = Rails.cache.fetch("vector_#{pid}") do
            Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
          end

          sub_nayyar = pr_narray - target_narray
          res        = (sub_nayyar * sub_nayyar).sum
          [pid, res]
        else
          nil
        end
      end
      sorts.compact.sort_by { |v| v[1] }.first(30).to_h

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

  ### テスト用DB切替 ###
  def change_db
    Thread.current[:request] = request

    case Rails.env
    when "production"; redirect_to "/"
    when "staging"
      ActiveRecord::Base.establish_connection(:production)
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/mnok/uploads/product_image/image"
      @link_base   = "https://www.mnok.net/"
      @bucket_name = "mnok"
    else
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/development.auction/uploads/product_image/image"
      @link_base   = "http://192.168.33.110:8087/"
      @bucket_name = Rails.application.secrets.aws_s3_bucket
    end
  end

  ### DB切替を戻す ###
  def restore_db
    if Rails.env == "staging"
      ActiveRecord::Base.establish_connection(:staging)
    end
  end

  ### S3 bucket 取得 ###
  def s3_resource
    Aws::S3::Resource.new(
      access_key_id:     Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region:            'ap-northeast-1', # Tokyo
    )
  end

  def s3_bucket
    s3_resource.bucket(@bucket_name)
  end
end
