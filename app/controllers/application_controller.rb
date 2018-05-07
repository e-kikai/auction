class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout 'layouts/application'

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  include ErrorHandlers if Rails.env.production? or Rails.env.staging?

  def after_sign_in_path_for(resource)
    "/myauction/"
  end
end
