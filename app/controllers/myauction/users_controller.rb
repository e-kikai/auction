class Myauction::UsersController < Myauction::ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to "/myauction/", notice: "ユーザ情報を変更しました"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(%w|name company tel zip addr_1 addr_2 addr_3 account|)
  end
end
