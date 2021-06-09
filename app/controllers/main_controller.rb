class MainController < ApplicationController
  def index
    @roots = Category.roots.order(:order_no) # カテゴリ

    # 新着
    # @new_products = Product.status(Product::STATUS[:start]).includes(:product_images).reorder(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)

    # トップページ公開検索条件
    # @searches = Search.where(publish: true).order("RANDOM()").limit(Search::TOPPAGE_COUNT)

    ### ヘルプ ###
    @helps = Help.where(target: 0).order(:order_no).limit(10)
    @infos = Info.where(target: 0).order(start_at: :desc).limit(10)

    ### VBPR・オススメ枠初期設定 ###
    products   = Product.includes(:product_images).limit(Product::NEWS_LIMIT)
    s_products = products.status(Product::STATUS[:start])

    if user_signed_in? # ログインユーザ
      @vbpr_products = DetailLog.vbpr_get(current_user.id, Product::NEWS_LIMIT) # VBPR結果
      # @bpr_products  = DetailLog.vbpr_get(@user.id, Product::NEWS_LIMIT, true) #BPR結果

      @watch_osusume = Product.osusume("watch_osusume", ip, current_user&.id).limit(Product::NEWS_LIMIT) # ウォッチオススメ
      @bid_osusume   = Product.osusume("bid_osusume", ip, current_user&.id).limit(Product::NEWS_LIMIT)   # 入札オススメ
      @cart_products = Product.osusume("cart", ip, current_user&.id).limit(Product::NEWS_LIMIT)          # 入札してみませんか
      @next_osusume  = Product.osusume("next", ip, current_user&.id).limit(Product::NEWS_LIMIT)          # こちらもオススメ
      @dl_products   = Product.osusume("detail_log", ip, current_user&.id).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
      @fol_products  = Product.osusume("follows", ip, current_user&.id).limit(Product::NEW_MAX_COUNT)    # フォロー新着
      @oft_products  = Product.osusume("often", ip, current_user&.id).limit(Product::NEWS_LIMIT)         # よく見る新着
    else # 非ログイン
      @dl_products = Product.osusume("detail_log", ip).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
      @dl_osusume  = Product.osusume("dl_osusume", ip).limit(Product::NEWS_LIMIT)    # 閲覧履歴に基づくオススメ
    end

    ### ユーザ共通 : 現在出品中の商品からのみ取得 ###
    @end_products  = Product.osusume("end").limit(Product::NEWS_LIMIT)          # まもなく終了
    @tool_news     = Product.osusume("news_tool").limit(Product::NEWS_LIMIT)    # 工具新着
    @machine_news  = Product.osusume("news_machine").limit(Product::NEWS_LIMIT) # 機械新着
    @zero_products = Product.osusume("zero").limit(Product::NEWS_LIMIT)         # 閲覧少

    ### 売れ筋商品 ###
    @populars      = Product.osusume("pops").limit(Product::NEWS_LIMIT)
  end

  def rss
    # 新着
    @products = Product.status(Product::STATUS[:start]).includes(:product_images, :category).search(news_week: Time.now.strftime("%F")).result.reorder(dulation_start: :desc)

    # 新着メール用
    @products = @products.reorder("RANDOM()").limit(12) if params[:mail]

    respond_to do |format|
      format.rss
    end
  end

  ### 売れ筋商品 ###
  def pops
    @pops       = Product.osusume("pops").limit(Product::NEWS_LIMIT)
    @pops_1000  = @pops .where(start_price: 0...2000)
    @pops_2000  = @pops .where(start_price: 2000...3000)
    @pops_3000  = @pops .where(start_price: 3000...4000)
    @pops_4000  = @pops .where(start_price: 4000...5000)
    @pops_5000  = @pops .where(start_price: 5000...6000)
    @pops_6000m = @pops .where(start_price: 6000...Float::INFINITY)

    ### 最近チェックした商品 ###
    @dl_products = Product.osusume("detail_log", ip, @user&.id).limit(Product::NEW_MAX_COUNT) # 最近チェックした商品
  end
end
