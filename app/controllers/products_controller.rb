class ProductsController < ApplicationController
  before_action :get_product,  only: [:show, :bids, :nitamono, :process_vector]
  before_action :get_populars, only: [:show, :bids]

  def index
    ### フィルタリング用パラメータ生成 ###
    pms = params.to_unsafe_h
    @pms = {
      keywords:    pms[:keywords].to_s.normalize_charwidth.strip.presence,
      category_id: pms[:category_id].presence,
      company_id:  pms[:company_id].presence,
      search_id:   pms[:search_id].presence,
      success:     pms[:success].presence,
      nitamono:    pms[:nitamono].presence,

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
    @products = Product.status(cond).includes(:product_images, :category, :user)
      .with_keywords(@keywords).search(@pms[:q]).result

    # 新着(週)
    if @pms[:news_week].present?
      date         = @pms[:news_week].to_date
      @products    = @products.news_week(date.strftime("%F"))

      @title       = "新着商品 #{(date - 6.day).strftime("%Y/%-m/%-d")} 〜 #{date.strftime("%-m/%-d")}"
      @description = "#{(date - 6.day).strftime("%Y/%-m/%-d")} 〜 #{date.strftime("%-m/%-d")}の新着機械・工具です。お買い得商品を探してみましょう。"
    end

    # 新着(日)
    if @pms[:news_day].present?
      date      = @pms[:news_day].to_date
      @products = @products.news_day(date.strftime("%F"))
      @title    = "#{date.strftime("%Y/%-m/%-d")} の新着商品"
    end

    # カテゴリ
    if @pms[:category_id].present?
      @category = Category.find(@pms[:category_id])
      @products = @products.where(category_id: @category.subtree_ids)
    end

    # 出品会社
    if @pms[:company_id].present?
      @company  = User.companies.find(@pms[:company_id])
      @products = @products.where(user_id: @pms[:company_id])
    end

    ### 似たもの・残り時間ソート ###
    if params[:nitamono].present?
      nitamono_products = @products.nitamono_sort(params[:nitamono], params[:page])
    elsif @pms[:q][:s] == "dulation_end asc"
      @products = @products.reorder(" CASE WHEN dulation_end <= CURRENT_TIMESTAMP THEN 2 ELSE 1 END, dulation_end ")
    end

    # ### オススメ ###
    case params[:osusume]
    when "v";
    when "b";
    when nil
    elsif

    end
    # if params[:osusume].present?
    #   @products = @products.osusume(params[:osusume])
    #   @title    = Product.osusume_title(params[:osusume])
    # end

    ### ページャ ###
    if params[:nitamono].present?
      @pproducts = Kaminari.paginate_array(nitamono_products, total_count: @products.count).page(params[:page])
    else
      @pproducts = @products.page(params[:page])
    end


    ### ウォッチリスト ###
    @watches = user_signed_in? ? current_user.watches.pluck(:product_id) : []

    # フィルタリングセレクタ
    @category_selector = @products.joins(:category).group(:category_id, "categories.name").reorder("count_id DESC").count
    @addr1_selector    = @products.group(:addr_1).reorder(:addr_1).count
    @sort_selector     = Product::SORT_SELECTOR

    @roots = Category.roots.order(:order_no)

    ### 表示切り替え ###
    session[:search_view] = params[:v] if Product::VIEW_SELECTOR.include? params[:v]

    ### 最近チェックした商品 ###
    dl_where     = user_signed_in? ? {user_id: current_user.id} : {ip: ip}
    @dl_products = Product.includes(:product_images).joins(:detail_logs).group(:id).where(detail_logs: dl_where)
                    .reorder("max(detail_logs.id)").limit(Product::NEW_MAX_COUNT)

  end

  def show
    @bid = @product.bids.new
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    if user_signed_in?
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: current_user.addr_1)
    end
  end

  # 入札履歴ページ
  def bids
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

  def nitamono
    @products = @product.nitamono(Product::NEW_MAX_COUNT)
  end

  def process_vector
    if @product.process_vector
      render plain: 'OK', status: 200
    else
      render plain: @product.errors.full_messages.join(' | '), status: 200
    end
  end

  private

  ### 商品情報取得 ###
  def get_product
    @product = Product.find(params[:id])
  end

  ### 人気商品 or 画像特徴ベクトル検索 ###
  def get_populars
    ### 人気商品 ###
    @popular_products = Product.related_products(@product).populars.limit(Product::NEW_MAX_COUNT)

    ### 似たものサーチ ###
    @nitamono_products = @product.nitamono(Product::NEW_MAX_COUNT)
  end

end
