class SearchLogsController < ApplicationController
  require 'resolv'

  def create
    status = SearchLog.create(
      category_id: params[:category_id],
      company_id:  params[:company_id],
      keywords:    params[:keywords],
      search_id:   params[:search_id],
      user_id:     user_signed_in? ? current_user.id : nil,

      nitamono_product_id: params[:nitamono_product_id],

      path:        params[:path],
      page:        params[:page],

      host:       (Resolv.getname(ip) rescue ""),
      ip:          ip,
      r:           params[:r],
      referer:     params[:referer],
      ua:          request.user_agent,

      utag:       session[:utag],
    ) ? "success" : "error"

    render json: { status: status }
  end
end
