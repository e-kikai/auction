class ToppageLogsController < ApplicationController
  require 'resolv'

  def create
    ip = request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip

    status = ToppageLog.create(
      user_id:    user_signed_in? ? current_user.id : nil,
      ip:         ip,
      host:       (Resolv.getname(ip) rescue ""),
      referer:    request.referer,
      ua:         request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end