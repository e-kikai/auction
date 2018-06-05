class Myauction::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_addrs

  private

  ### ユーザ情報登録しているかどうかチェック ###
  def check_user_addrs
    columns = %w|name tel zip addr_1 addr_2 addr_3|

    if controller_name != "users" && columns.any? { |c| current_user[c].blank? }
      @user = current_user
      flash.now[:alert] = "商品送付先など、ユーザ情報登録を行ってください"

      render "/myauction/users/edit"
    end
  end

  # 出品会社チェック
  def check_seller
    render "/myauction/" unless current_user.seller?
  end
end
