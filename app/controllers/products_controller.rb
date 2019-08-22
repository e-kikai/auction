class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:conf, :bid, :result]
  before_action :get_product,        only: [:show, :conf, :bids]

  def index
    pms = params.to_unsafe_h
    @pms = {
      keywords:    pms[:keywords].to_s.normalize_charwidth.strip.presence,
      category_id: pms[:category_id].presence,
      company_id:  pms[:company_id].presence,

      news_week:   pms[:news_week].presence,
      news_day:    pms[:news_day].presence,

      success:     pms[:success].presence,
      q:           pms[:q].presence || {},

      search_id:   pms[:search_id].presence,
    }.compact

    #### 検索条件からパラメータ取得 ###
    if params[:search_id].present?
      search = Search.find(params[:search_id])
      @pms         = search.params.merge(@pms)
      @title       = search.name
      @description = search.description
    end

    ### 検索キーワード ###
    @keywords = @pms[:keywords].to_s.normalize_charwidth.strip

    ### 終了後の表示 ###
    cond = params[:success].present? ? Product::STATUS[:success] : Product::STATUS[:start]

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

    ### ページャ ###
    @pproducts = @products.page(params[:page])

    # フィルタリング
    @select_categories = @products.joins(:category).group(:category_id).group("categories.name").reorder("count_id DESC").count
    @select_addr1      = @products.group(:addr_1).reorder(:addr_1).count

    @roots = Category.roots.order(:order_no)

    # 最近チェックした商品
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
    @products = Product.status(Product::STATUS[:start]).with_keywords(@keywords).includes(:product_images)
    @products = @products.order(" CASE WHEN product_images.id IS NULL THEN 1 ELSE 9 END, RANDOM() ").limit(4)

    @res = params[:res]

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
