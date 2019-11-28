class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:conf, :bid, :result]
  before_action :get_product,        only: [:show, :conf, :bids]

  def index
    ### フィルタリング用パラメータ生成 ###
    pms = params.to_unsafe_h
    @pms = {
      keywords:    pms[:keywords].to_s.normalize_charwidth.strip.presence,
      category_id: pms[:category_id].presence,
      company_id:  pms[:company_id].presence,
      search_id:   pms[:search_id].presence,
      success:     pms[:success].presence,

      news_week:   pms[:news_week].presence,
      news_day:    pms[:news_day].presence,

      q:           (pms[:q].presence || {}).compact,
    }.compact

    ### 検索条件からパラメータ取得 ###
    if params[:search_id].present?
      search = Search.find(params[:search_id])
      @pms         = search.params.merge(@pms)
      @title       = search.name
      @description = search.description
    end

    ### 検索キーワード ###
    @keywords = @pms[:keywords].to_s

    ### 落札済と出品中の表示切替 ###
    cond = case params[:success]
    when "success"; Product::STATUS[:success]
    when "mix";     Product::STATUS[:mix]
    when "start";   Product::STATUS[:start]
    else;           Product::STATUS[:mix]
    end
    # cond = params[:success].present? ? Product::STATUS[:success] : Product::STATUS[:start]

    # 初期検索クエリ作成
    @search = Product.status(cond).with_keywords(@keywords).search(@pms[:q])

    # 新着(週)
    if @pms[:news_week].present?
      date = @pms[:news_week].to_date
      @search   = @search.result.search(news_week: date.strftime("%F"))

      @title       = "新着商品 #{(date - 6.day).strftime("%Y/%-m/%-d")} 〜 #{date.strftime("%-m/%-d")}"
      @description = "#{(date - 6.day).strftime("%Y/%-m/%-d")} 〜 #{date.strftime("%-m/%-d")}の新着機械・工具です。お買い得商品を探してみましょう。"
    end

    # 新着(日)
    if @pms[:news_day].present?
      date = @pms[:news_day].to_date
      @search   = @search.result.search(news_day: date.strftime("%F"))

      @title  = "#{date.strftime("%Y/%-m/%-d")} の新着商品"
    end

    # カテゴリ
    if @pms[:category_id].present?
      @category = Category.find(@pms[:category_id])
      @search   = @search.result.search(category_id_in: @category.subtree_ids)
    end

    # 出品会社
    if @pms[:company_id].present?
      @company = User.companies.find(@pms[:company_id])
      @search  = @search.result.search(user_id_eq: @pms[:company_id])
    end

    @products  = @search.result.includes(:product_images, :category, :user)

    ### 残り時間並び順 ###
    if @pms[:q][:s] == "dulation_end asc"
      @products = @products.reorder(" CASE WHEN dulation_end <= CURRENT_TIMESTAMP THEN 2 ELSE 1 END, dulation_end ")
    end

    ### ページャ ###
    @pproducts = @products.page(params[:page])

    # フィルタリング
    @select_categories = @products.joins(:category).group(:category_id).group("categories.name").reorder("count_id DESC").count
    @select_addr1      = @products.group(:addr_1).reorder(:addr_1).count

    @select_sort = {
      "出品 : 新着"   => "dulation_start asc",
      "出品 : 古い"   => "dulation_start desc",
      "価格 : 安い"   => "max_price asc",
      "価格 : 高い"   => "max_price desc",
      "即決 : 安い"   => "prompt_dicision_price asc",
      "即決 : 高い"   => "prompt_dicision_price desc",
      "入札 : 多い"   => 'bids_count desc',
      "入札 : 少ない" => "bids_count asc",
      "残り時間"      => "dulation_end asc",
    }

    @roots = Category.roots.order(:order_no)

    ### 表示切り替え ###
    if ["panel", "list"].include? params[:v]
      session[:search_view] = params[:v]
    end

    ### 最近チェックした商品 ###
    where_query = user_signed_in? ? {user_id: current_user.id} : {ip: ip}

    detaillog_ids = DetailLog.order(id: :desc).limit(Product::NEW_MAX_COUNT).select(:product_id).where(where_query)
    @detaillog_products = Product.includes(:product_images).where(id: detaillog_ids)
  end

  def show
    @bid = @product.bids.new
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    if user_signed_in?
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: current_user.addr_1)
    end

    # このカテゴリの人気商品
    # @category_products = Product.status(Product::STATUS[:start]).includes(:product_images)
    #   .where(category_id: @product.category.subtree_ids).where.not(id: @product.id)
    #   .order(bids_count: :desc).limit(Product::NEW_MAX_COUNT)

    # 人気商品
    @popular_products = Product.related_products(@product).populars.limit(Product::NEW_MAX_COUNT)
  end

  # 入札履歴ページ
  def bids
    # 人気商品
    @popular_products = Product.related_products(@product).populars.limit(Product::NEW_MAX_COUNT)
  end

  def ads
    ### 検索キーワード ###
    @keywords = params[:keywords].to_s.normalize_charwidth.strip

    # クエリ作成
    lim = 5
    @products = Product.status(Product::STATUS[:start]).with_keywords(@keywords).includes(:product_images)
    @products = @products.reorder(" RANDOM() ").limit(lim)

    if lim > @products.count
      @products += Product.status(Product::STATUS[:start]).reorder(" RANDOM() ").limit(lim - @products.count)
    end

    @res = params[:res]

    response.headers['X-Frame-Options'] = 'ALLOWALL'

    render layout: false
  end

  private

  def get_product
    @product = Product.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end

end
