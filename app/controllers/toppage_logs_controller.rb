class ToppageLogsController < ApplicationController
  require 'resolv'

  def create
    status = ToppageLog.create(
      user_id: user_signed_in? ? current_user.id : nil,
      ip:      ip,
      host:    (Resolv.getname(ip) rescue ""),
      r:       params[:r],
      referer: params[:referer],
      ua:      request.user_agent,

      utag:       session[:utag],
    ) ? "success" : "error"

    render json: { status: status }
  end
end
