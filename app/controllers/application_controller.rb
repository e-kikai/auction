class ApplicationController < ActionController::Base
  require 'resolv'

  before_action :make_utag

  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  before_action :get_watches

  layout 'layouts/application'

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  include ErrorHandlers if Rails.env.production? or Rails.env.staging?

  def after_sign_in_path_for(resource)
    "/myauction/"
  end

  def ip
    request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
  end

  def host
    Resolv.getname(ip) rescue ""
  end

  private

  ### 未ログインユーザ追跡タグ生成 ###
  def make_utag
    # botを排除
    if request.user_agent !~ /bot|crawl|spider|health/i && DetailLog.check_robot(host, ip)
      session[:utag] = SecureRandom.alphanumeric(10) if session[:utag].blank?
      # logger.error "  #{session[:utag]} :: #{request.user_agent} :: #{host}"
    else
      request.session_options[:skip] = true
    end
  end

  ### ウォッチ一覧を取得 ###
  def get_watches
    products = Product.status(Product::STATUS[:start])

    @watches = case
    when user_signed_in?;         current_user.watches
    when session[:utag].present?; Watch.where(utag: session[:utag], user_id: nil)
    else;                         Watch.none
    end

    @watch_products = Product.status(Product::STATUS[:start]).where(id: @watches.select(:product_id))
    @watch_pids     = @watch_products.pluck(:id)
    @watch_end_min  = @watch_products.minimum(:dulation_end)

  end
end
