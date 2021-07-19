class WatchesController < ApplicationController
  def index
    redirect_to "/myauction/watches" if user_signed_in?

    @search   = @watches.joins(:product).includes(product: [:user, :category, :product_images, max_bid: [:user]])
      .where(products: {template: false})
      .search(params[:q])
    @lwatches = @search.result

    @lwatches = if params[:result].present?
      @lwatches.where("products.dulation_end <= ?", Time.now).order("products.dulation_end DESC")
    else
      @lwatches.where("products.dulation_end > ?", Time.now).order("products.dulation_end")
    end

    @pwatches = @lwatches.page(params[:page])

    ### ウォッチオススメ ###
    @watch_osusume = Product.limit(Product::NEW_MAX_COUNT).osusume("watch_osusume", {utag: session[:utag]})
  end

  ### ウォッチ切替 ###
  def toggle
    @product_id = params[:id]
    @watch      = @watches.find_by(product_id: @product_id)

    @watch_length = @watch_pids.length

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
      @watch_length += 1

      :on
    else
      @watch.soft_destroy!
      @watch_length -= 1

      :off
    end


  end
end
