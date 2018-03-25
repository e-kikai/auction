class DetailLogsController < ApplicationController
  require 'resolv'

  def create
    status = DetailLog.create(
      product_id: params[:product_id],
      user_id:    user_signed_in? ? current_user.id : nil,
      ip:         User.ip,
      host:       (Resolv.getname(User.ip) rescue ""),
      referer:    request.referer,
      ua:         request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end
