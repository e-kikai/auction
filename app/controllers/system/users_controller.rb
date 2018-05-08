class System::UsersController < System::ApplicationController
  def index
    @search = User.search(params[:q])

    @users  = @search.result.order(created_at: :desc)
    @pusers = @users.page(params[:page]).per(100)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_confirmation!

    if @user.save
      redirect_to "/system/users/", notice: "#{@user.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.skip_reconfirmation!

    if @user.update(user_params)
      redirect_to "/system/users/", notice: "#{@user.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.soft_destroy!
    redirect_to "/system/users/", notice: "#{@user.name}を削除しました"
  end

  # def sign_in
  #   @user = User.find(params[:id])
  #
  #   current_user = @user
  #
  #   redirect_to "/myauction/", notice: "#{@user.name}で代理ログインしました"
  # end

  def edit_password
    @user = User.find(params[:id])
  end

  def update_password
    @user = User.find(params[:id])
    @user.skip_reconfirmation!

    if @user.update(password_params)
      redirect_to "/system/users/", notice: "#{@user.name}をのパスワード変更しました"
    else
      render :edit_password
    end
  end

  private

  def user_params
    params.require(:user).permit(%w|email password name company tel zip addr_1 addr_2 addr_3 account bank seller charge fax url license business_hours note allow_mail confirmed_at result_message machinelife_company_id header_image|)
  end

  def password_params
    params.require(:user).permit(%w|password password_confirmation|)
  end
end
