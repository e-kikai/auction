class SearchLogsController < ApplicationController
  def create
    ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip

    status = SearchLog.create(
      category_id: params[:category_id],
      company_id:  params[:company_id],
      keywords:    params[:keywords],
      search_id:   params[:search_id],
      user_id:     user_signed_in? ? current_user.id : nil,
      ip:          ip,
      host:        Socket.gethostname,
      referer:     request.referer,
      ua:          request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end
