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
    params.require(:user).permit(:email, :name, :company, :tel, :zip, :addr_1, :addr_2, :addr_3, :account, :bank, :charge, :fax, :url, :license, :business_hours, :note, :allow_mail, :result_message, :header_image, :remove_header_image, industry_ids: [])
  end
end
