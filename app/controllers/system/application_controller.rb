class System::ApplicationController < ApplicationController
  USERS = { Rails.application.secrets.digest_user => Rails.application.secrets.digest_password }

  before_action :digest_auth

  private

  def digest_auth
    authenticate_or_request_with_http_digest { |user| USERS[user] }
  end
end
