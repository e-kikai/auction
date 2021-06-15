class DetailLogsController < ApplicationController
  require 'resolv'

  def index
    @products = Products.includes(:product_images).joins(:detail_logs).where(detail_logs: dl_where)
      .reorder("max(detail_logs.id) DESC")


    @dl_osusume  = Product.osusume("dl_osusume", ip).limit(Product::NEWS_LIMIT)    # 閲覧履歴に基づくオススメ

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
    ) ? "success" : "error"

    render json: { status: status }
  end
end
