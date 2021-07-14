class DetailLogsController < ApplicationController
  require 'resolv'

  def index
    redirect_to "/myauction/detail_logs" if user_signed_in?

    @products = Product.includes(:product_images).joins(:detail_logs)
      .select("products.*, detail_logs.created_at as ca")
      .reorder("detail_logs.id DESC")
      .where.not(detail_logs: {r: ["reload", "back"]})
      .where(detail_logs: {utag: session[:utag]})
      # .where(detail_logs: {ip: ip})

    # @dl_osusume  = Product.osusume("dl_osusume", {ip: ip}).limit(Product::NEWS_LIMIT) # 閲覧履歴に基づくオススメ
    @dl_osusume  = Product.osusume("dl_osusume", {utag: session[:utag]}).limit(Product::NEWS_LIMIT) # 閲覧履歴に基づくオススメ

    @pproducts = @products.page(params[:page]).per(50)
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
