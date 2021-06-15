class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :make_utag

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

  private

  ### 未ログインユーザ追跡タグ生成 ###
  def make_utag
    session[:utag] = SecureRandom.alphanumeric(10) if session[:utag].blank?
  end
end
