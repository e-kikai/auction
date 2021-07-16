class Users::SessionsController < Devise::SessionsController
  def create
    super

    ### ウォッチリストを結合 ###
    if !session[:system_account] && session[:utag].present? && user_signed_in?
      Watch.where(soft_destroyed_at: nil, user_id: nil, utag: session[:utag]).update_all(user_id: current_user&.id)
    end
  end
end