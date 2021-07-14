class WatchesController < ApplicationController
  def index
    redirect_to "/myauction/watches" if user_signed_in?

    @search    = @watch_products.search(params[:q])
    @products  = @search.result

    @products = if params[:result].present?
      @products.where("dulation_end <= ?", Time.now).order(dulation_end: :desc)
    else
      @products.where("dulation_end > ?", Time.now).order(:dulation_end)
    end

    @pproducts = @products.page(params[:page]).per(10).preload(:user, :category, :product_images, max_bid: :user)

    @popular_products = Product.related_products(@products).populars.limit(Product::NEW_MAX_COUNT)
  end

  ### ウォッチ切替 ###
  def toggle
    @product_id = params[:id]
    @watch      = @watches.find_by(product_id: @product_id)

    @res = if @watch.blank? # 登録
      @watch = Watch.create(
        product_id: @product_id,
        user_id:    user_signed_in? ? current_user.id : nil,

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

    @watch_count = @watches.length
  end
end
