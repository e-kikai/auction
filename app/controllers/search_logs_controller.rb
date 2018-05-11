class SearchLogsController < ApplicationController
  require 'resolv'

  def create
    ip = request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip

    status = SearchLog.create(
      category_id: params[:category_id],
      company_id:  params[:company_id],
      keywords:    params[:keywords],
      search_id:   params[:search_id],
      user_id:    user_signed_in? ? current_user.id : nil,
      host:       (Resolv.getname(ip) rescue ""),
      ip:          ip,
      referer:     request.referer,
      ua:          request.user_agent,
    ) ? "success" : "error"

    render json: { status: status }
  end
end
