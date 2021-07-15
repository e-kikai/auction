class DetailLogsController < ApplicationController
  require 'resolv'

  def index
    redirect_to "/myauction/detail_logs" if user_signed_in?

    @detail_logs = DetailLog.joins(:product).includes(product: [:user, :product_images])
      .where.not(r: ["reload", "back"]).where(products: {template: false})
      .where(utag: session[:utag]).reorder(id: :desc)

    @pdetail_logs = @detail_logs.page(params[:page]).per(50)

    ### 閲覧履歴に基づくオススメ###
    @dl_osusume  = Product.osusume("dl_osusume", {utag: session[:utag]}).limit(Product::NEW_MAX_COUNT)
  end

  def create
    status = DetailLog.create(
      product_id: params[:product_id],
      user_id:    user_signed_in? ? current_user.id : nil,
      r:          params[:r],
      ip:         ip,
      host:       (Resolv.getname(ip) rescue ""),
      referer:    params[:referer],
      ua:         request.user_agent,

      utag:       session[:utag],
      nonlogin:   user_signed_in? ? false : true,

    ) ? "success" : "error"

    render json: { status: status }
  end
end
