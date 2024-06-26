class System::PlaygroundController < ApplicationController
  require "open3"
  include Exports

  before_action :change_db
  after_action  :restore_db

  before_action :user_selector, only: [:vbpr_top, :vbpr_detail]

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
    uid            = params[:user_id]

    if uid.present?
      ### VBPR結果取得 ###
      @vbpr_products = DetailLog.vbpr_get(uid, limit)

      ### BPR結果取得 ###
      @bpr_products  = DetailLog.vbpr_get(uid, limit, true)

      ### 履歴他 ###
      # detaillog_pids = DetailLog.where(user_id: uid, created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      # @detaillog_products = products.where(id: detaillog_pids)

      @watch_products = products.joins(:watches).group(:id)
        .where(watches: {user_id: uid, soft_destroyed_at: nil}).reorder("max(watches.created_at)")

      @bid_products   = products.joins(:bids).group(:id)
        .where(bids: {user_id: uid, soft_destroyed_at: nil}).reorder("max(bids.created_at)")

      ### 入札してみませんか ###
      cart_log_pids  = DetailLog.where(user_id: uid).select(:product_id).group(:product_id).order("count(product_id) DESC").limit(limit)
      watch_pids     = Watch.where(user_id: uid, created_at: DetailLog::VBPR_RANGE).select(:product_id).order(id: :desc).limit(limit)
      @cart_products = start_products
        .where(id: watch_pids)
        .or(start_products.where(id: cart_log_pids))
        .where.not(id: bid_pids).reorder("random()")

      ### 最近チェックした商品 ###
      @detaillog_products = products.joins(:detail_logs).group(:id)
        .where(detail_logs: {user_id: uid}).reorder("max(detail_logs.created_at)")

      # # ### 入札履歴からのオススメ ###
      # detaillogs_names = @detaillog_products.map { |pr| pr.name.split }.flatten.uniq.join("|")
      # @detail_osusume = products.where("name =~ ", "(#{detaillogs_names})")

      ### ウォッチリストからのオススメ ###
      watch_names    = @watch_products.map { |pr| pr.name.split }.flatten.uniq.join("|")
      @watch_osusume = start_products
        .where("products.name ~ ?", "(#{watch_names})")
        .where.not(id: @watch_products.limit(nil)).where.not(id: @bid_products.limit(nil))
        .reorder("random()")

      ### 購入履歴に基づくオススメ ###
      bid_names    = @bid_products.map { |pr| pr.name.split }.flatten.uniq.join("|")
      @bid_osusume = start_products
        .where("products.name ~ ?", "(#{bid_names})")
        .where.not(id: @watch_products.limit(nil)).where.not(id: @bid_products.limit(nil))
        .reorder("random()")

    else
      ### 最近チェックした商品 for IP ###
      @ip = ip
      @detaillog_products = products.joins(:detail_logs).group(:id)
        .where(detail_logs: {ip: ip}).reorder("max(detail_logs.created_at)")

      ### 閲覧履歴からのオススメ ###
      detaillog_names = @detaillog_products.map { |pr| pr.name.split }.flatten.uniq.join("|")

      @detaillog_osusume = start_products
        .where("products.name ~ ?", "(#{detaillog_names})").where.not(id: @detaillog_products.limit(nil))
        .reorder("random()")
    end

    ### ユーザ共通 : 現在出品中の商品からのみ取得 ###
    @end_products   = start_products.reorder(:dulation_end) # まもなく終了

    news            = start_products.reorder(dulation_start: :desc)
    @tool_news      = news.where(category_id: Category.find(1).subtree_ids) rescue [] # 機械新着
    @machine_news   = news.where(category_id: Category.find(107).subtree_ids) rescue [] # 工具新着

    @zero_products  = start_products.joins(:detail_logs).group(:id).reorder("count(detail_logs.id), random()") # 閲覧少
  end

  def vbpr_top
    @roots    = Category.roots.order(:order_no) # カテゴリ
    @searches = Search.where(publish: true).order("RANDOM()").limit(Search::TOPPAGE_COUNT) # 特集
    @helps    = Help.where(target: 0).order(:order_no).limit(Help::NEWS_LIMIT) # ヘルプ
    @infos    = Info.where(target: 0).order(start_at: :desc).limit(Info::NEWS_LIMIT)

    ### 初期設定 ###
    products   = Product.includes(:product_images).limit(Product::NEWS_LIMIT)
    s_products = products.status(Product::STATUS[:start])

    # if user_signed_in? # ログインユーザ
    if @user
      @vbpr_products = DetailLog.vbpr_get(@user.id, Product::NEWS_LIMIT) # VBPR結果
      # @bpr_products  = DetailLog.vbpr_get(@user.id, Product::NEWS_LIMIT, true) #BPR結果

      @watch_osusume = Product.osusume("watch_osusume", {user_id: @user&.id}).limit(Product::NEWS_LIMIT) # ウォッチオススメ
      @bid_osusume   = Product.osusume("bid_osusume", {user_id: @user&.id}).limit(Product::NEWS_LIMIT)   # 入札オススメ
      @cart_products = Product.osusume("cart", {user_id: @user&.id}).limit(Product::NEWS_LIMIT)          # 入札してみませんか
      @next_osusume  = Product.osusume("next", {user_id: @user&.id}).limit(Product::NEWS_LIMIT)          # こちらもオススメ
      @dl_products   = Product.osusume("detail_log", {user_id: @user&.id}).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
      @fol_products  = Product.osusume("follows", {user_id: @user&.id}).limit(Product::NEW_MAX_COUNT)    # フォロー新着
      @oft_products  = Product.osusume("often", {user_id: @user&.id}).limit(Product::NEWS_LIMIT)         # よく見る新着

    else # 非ログイン
      # @dl_products = Product.osusume("detail_log", {ip: ip}).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
      # @dl_osusume  = Product.osusume("dl_osusume", {ip: ip}).limit(Product::NEWS_LIMIT)    # 閲覧履歴に基づくオススメ
      @dl_products = Product.osusume("detail_log", {utag: session[:utag]}).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
      @dl_osusume  = Product.osusume("dl_osusume", {utag: session[:utag]}).limit(Product::NEWS_LIMIT)    # 閲覧履歴に基づくオススメ
    end

    ### ユーザ共通 : 現在出品中の商品からのみ取得 ###
    @end_products  = Product.osusume("end").limit(Product::NEWS_LIMIT)          # まもなく終了
    @tool_news     = Product.osusume("news_tool").limit(Product::NEWS_LIMIT)    # 工具新着
    @machine_news  = Product.osusume("news_machine").limit(Product::NEWS_LIMIT) # 機械新着
    @zero_products = Product.osusume("zero").limit(Product::NEWS_LIMIT)         # 閲覧少

    render template: "main/index_02"
  end

  def vbpr_detail
    @product = Product.find(params[:id])

    @bid = @product.bids.new
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    if user_signed_in?
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: current_user.addr_1)
    end

    ### 人気商品 ###
    @popular_products = Product.related_products(@product).populars.limit(Product::NEW_MAX_COUNT)

    ### 似たものサーチ ###
    # @nitamono_products = @product.nitamono(Product::NEW_MAX_COUNT)
    @nitamono_products = @product.nitamono_02.limit(Product::NEW_MAX_COUNT).status(Product::STATUS[:start])

    ### 終了時おすすめ ###
    key_array =  %w|dl_osusume|
    key_array += %w|v watch_osusume bid_osusume cart next often| if @user.present? # ログイン時

    if @product.finished?
      ### オススメをランダム(0件でないもの)取得 ###
      key_array.shuffle.each do |key|
        @fin_osusume = case key
        when "v"; DetailLog.vbpr_get(current_user&.id, Product::NEW_MAX_COUNT) # VBPR結果
        else;     Product.osusume(key, {user_id: current_user&.id}).limit(Product::NEW_MAX_COUNT)
        end

        next if @fin_osusume.length == 0 # ない場合は次へ
        key_array.delete(key)
        @fin_osusume_titles = Product.osusume_titles(key)
        break
      end
    end

   ### オススメをランダム(0件でないもの)取得 ###
    key_array +=  %w|end news_tool news_machine zero| # そのほかオススメ項目追加

    key_array.shuffle.each do |key|
      @osusume = case key
      when "v"; DetailLog.vbpr_get(current_user&.id, Product::NEW_MAX_COUNT) # VBPR結果
      else;     Product.osusume(key, {user_id: current_user&.id}).limit(Product::NEW_MAX_COUNT)
      end

      next if @osusume.length == 0 # ない場合は次へ
      @osusume_titles = Product.osusume_titles(key)
      break
    end

    render template: "products/show_02"
  end

  def categories
    @categories = Category.includes(:products).order(:id)

    respond_to do |format|
      format.csv {
        export_csv "categories.csv"
      }
    end
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

      CarrierWave.configure do |config|
        config.asset_host = "https://s3-ap-northeast-1.amazonaws.com/mnok"
      end
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

### ユーザセレクタ ###
def user_selector
  dls    = DetailLog.where(created_at: DetailLog::VBPR_RANGE)
  dl_cnt = dls.group(:user_id).order("count_all DESC").count
  wa_cnt = Watch.where(created_at: DetailLog::VBPR_RANGE).group(:user_id).count
  bi_cnt = Bid.where(created_at: DetailLog::VBPR_RANGE).group(:user_id).count

  @user_selector = User.where(id: dls.select(:user_id)).order(:id)
    .map { |us| ["#{us.id} : #{us.company} #{us.name} (#{bi_cnt[us.id].to_i} / #{wa_cnt[us.id].to_i} / #{dl_cnt[us.id].to_i})", us.id] }

  ### ユーザ情報 ###
  @user = case
  when params[:user_id].present?; User.find(params[:user_id])
  when user_signed_in?;           current_user
  else;                           nil
  end
end
