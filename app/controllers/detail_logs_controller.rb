class DetailLogsController < ApplicationController
  require 'resolv'

  def create
    status = DetailLog.create(
      product_id: params[:product_id],
      user_id:    user_signed_in? ? current_user.id : nil,
      r:          params[:r],
      ip:         ip,
      host:       (Resolv.getname(ip) rescue ""),
      referer:    params[:referer],
      ua:         request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end
