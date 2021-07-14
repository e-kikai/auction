class Myauction::WatchesController <  Myauction::ApplicationController
  def index
    @search    = current_user.watch_products.search(params[:q])

    @products  = @search.result

    @products = if params[:result].present?
      @products.where("dulation_end <= ?", Time.now).order(dulation_end: :desc)
    else
      @products.where("dulation_end > ?", Time.now).order(:dulation_end)
    end

    @pproducts = @products.page(params[:page]).per(10).preload(:user, :category, :product_images, max_bid: :user)

    @popular_products = Product.related_products(@products).populars.limit(Product::NEW_MAX_COUNT)
  end

  def create
    @watch = current_user.watches.new(product_id: params[:id])
    if @watch.save
      redirect_to "/myauction/watches", notice: "ウォッチリストに登録しました"
    else
      redirect_to "/myauction/watches", alert: "既にウォッチリストに登録されています"
    end
  end

  def destroy
    @watch = current_user.watches.find_by(product_id: params[:id])
    @watch.soft_destroy!
    redirect_to "/myauction/watches/", notice: "ウォッチリストから商品を削除しました"
  end

  ### ウォッチ切替 ###
  def toggle
    @product_id = params[:id]
    @watch      = current_user.watches.find_by(product_id: @product_id)

    @res = if @watch.blank? # 登録
      @watch = current_user.watches.create(
        product_id: @product_id,
        r:          params[:r],
        # referer:    params[:referer],
        referer:    request.referer,
        ip:         ip,
        host:       (Resolv.getname(ip) rescue ""),
        ua:         request.user_agent,

        utag:       session[:utag],
        nonlogin:   user_signed_in? ? false : true,
      )
      :on
    else
      @watch.soft_destroy!
      :off
    end
  end
end
