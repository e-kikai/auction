class System::ApplicationController < ApplicationController
  USERS = { Rails.application.secrets.digest_user => Rails.application.secrets.digest_password }

  before_action :digest_auth

  private

  def digest_auth
    authenticate_or_request_with_http_digest { |user| USERS[user] }

    ### 管理者はログを取得しない ###
    session[:system_account] = (Rails.env.development? ? false : true);

    ### 管理者ユーザ ###
    @system_user_id = case Rails.env
    when "production"; 19
    when "staging";    2
    else;              5
    end
  end
end
