class ToppageLogsController < ApplicationController
  def create
    ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip

    status = ToppageLog.create(
      user_id:    user_signed_in? ? current_user.id : nil,
      ip:         ip,
      host:       Socket.gethostname,
      referer:    request.referer,
      ua:         request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end
