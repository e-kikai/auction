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
    prs = Product.limit(Product::NEWS_LIMIT)

    if user_signed_in? # ログインユーザ
      @vbpr_products = DetailLog.vbpr_get(current_user&.id, Product::NEWS_LIMIT) # VBPR結果
      # @bpr_products  = DetailLog.vbpr_get(@user.id, Product::NEWS_LIMIT, true) #BPR結果

      dl_where = {user_id: current_user&.id}
      @watch_osusume = prs.osusume("watch_osusume", dl_where)                        # ウォッチオススメ
      @bid_osusume   = prs.osusume("bid_osusume",dl_where)                           # 入札オススメ
      @cart_products = prs.osusume("cart",dl_where)                                  # 入札してみませんか
      @next_osusume  = prs.osusume("next",dl_where)                                  # こちらもオススメ
      @oft_products  = prs.osusume("often",dl_where)                                 # よく見る新着
      @fol_products  = prs.osusume("follows",dl_where).limit(Product::NEW_MAX_COUNT) # フォロー新着

    else # 非ログイン
      # @dl_osusume  = Product.osusume("dl_osusume", {ip: ip}).limit(Product::NEWS_LIMIT)    # 閲覧履歴に基づくオススメ
      @dl_osusume  = prs.osusume("dl_osusume", {utag: session[:utag]}) # 閲覧履歴に基づくオススメ
    end

    ### ユーザ共通 : 現在出品中の商品からのみ取得 ###
    @end_products  = prs.osusume("end")          # まもなく終了
    @tool_news     = prs.osusume("news_tool")    # 工具新着
    @machine_news  = prs.osusume("news_machine") # 機械新着
    @zero_products = prs.osusume("zero")         # 閲覧少

    ### 売れ筋商品 ###
    @populars      = prs.osusume("pops")
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
      .reorder("(CASE WHEN prompt_dicision_price IS NULL THEN start_price ELSE prompt_dicision_price END), pr2.count DESC, dulation_end")
      # .reorder("products.start_price, pr2.count DESC, products.dulation_end")

    @pops = pops_rate.map do |lank, rate|
      {
        lank:     lank,
        title:    rate[1],
        # products: @products.where(start_price: rate[0])
        products: @products.where("(CASE WHEN prompt_dicision_price IS NULL THEN start_price ELSE prompt_dicision_price END) BETWEEN ? AND ? ", rate[0].first, rate[0].last)
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
    @products = Product.osusume("pops")
      .reorder("(CASE WHEN prompt_dicision_price IS NULL THEN start_price ELSE prompt_dicision_price END), pr2.count DESC, dulation_end")
      .where("(CASE WHEN prompt_dicision_price IS NULL THEN start_price ELSE prompt_dicision_price END) BETWEEN ? AND ? ", rate[0].first, rate[0].last)
        # .where(start_price: rate[0])
        # .reorder("products.start_price, pr2.count DESC, products.dulation_end")
      end

  private

  ### 最近チェックした商品 ###
  def dl_products
    dl_where = user_signed_in? ? {user_id: current_user&.id} : {utag: session[:utag]}
    @dl_products = Product.osusume("detail_log", dl_where).limit(Product::NEW_MAX_COUNT)
  end

  def pops_rate
     {
      "1000"  => [0...2000,             "最低価格1,000円台の売れ筋商品"],
      "2000"  => [2000...3000,          "最低価格2,000円台の売れ筋商品"],
      "3000"  => [3000...4000,          "最低価格3,000円台の売れ筋商品"],
      "4000"  => [4000...5000,          "最低価格4,000円台の売れ筋商品"],
      "5000"  => [5000...6000,          "最低価格5,000円台の売れ筋商品"],
      "6000m" => [6000...9_999_999_999, "最低価格6,000円以上の売れ筋商品"],
    }
  end
end
