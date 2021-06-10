class MainController < ApplicationController
  before_action :dl_products

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
      @fol_products  = Product.osusume("follows", ip, current_user&.id).limit(Product::NEW_MAX_COUNT)    # フォロー新着
      @oft_products  = Product.osusume("often", ip, current_user&.id).limit(Product::NEWS_LIMIT)         # よく見る新着
    else # 非ログイン
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
    @products   = Product.osusume("pops").limit(Product::NEWS_LIMIT)
      .reorder("products.start_price, pr2.count DESC, products.dulation_end")

    @pops = pops_rate.map do |lank, rate|
      {
        lank:     lank,
        title:    rate[1],
        products: @products.where(start_price: rate[0])
      }
    end

    respond_to do |format|
      format.html { @products = @products.limit(12) }
      format.rss  { render template: "/main/rss.rss.builder" }
    end
  end

  def pops_lank
    redirect_to "/pops/" unless pops_rate.key? params[:lank]

    rate      = pops_rate[params[:lank]]
    @title    = rate[1]
    @lank     = params[:lank]
    @products = Product.osusume("pops").where(start_price: rate[0])
      .reorder("products.start_price, pr2.count DESC, products.dulation_end")
  end

  private

  ### 最近チェックした商品 ###
  def dl_products
    @dl_products = Product.osusume("detail_log", ip, current_user&.id).limit(Product::NEW_MAX_COUNT)
  end

  def pops_rate
     {
      "1000"  => [0...2000,               "最低価格1,000円台の売れ筋商品"],
      "2000"  => [2000...3000,            "最低価格2,000円台の売れ筋商品"],
      "3000"  => [3000...4000,            "最低価格3,000円台の売れ筋商品"],
      "4000"  => [4000...5000,            "最低価格4,000円台の売れ筋商品"],
      "5000"  => [5000...6000,            "最低価格5,000円台の売れ筋商品"],
      "6000m" => [6000...Float::INFINITY, "最低価格6,000円以上の売れ筋商品"],
    }
  end
end
