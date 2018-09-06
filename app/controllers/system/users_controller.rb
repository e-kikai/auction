class System::UsersController < System::ApplicationController
  include Exports

  def index
    @search = User.search(params[:q])

    @users  = @search.result.order(created_at: :desc).includes(:industries)
    @pusers = @users.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv {
        @users = @users.where(allow_mail: true)
        export_csv "mailaddress_list.csv"
      }
    end
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

  def signin
    @user = User.find(params[:id])

    sign_in(:user, @user, bypass: true)

    redirect_to "/myauction/", notice: "#{@user.name}で代理ログインしました"
  end

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


  def total
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    # 取得
    rstart = @date.beginning_of_month
    rend   = @date.end_of_month

    # @users = User.includes(:bids).where("created_at <= ?", rend).where("count(bids.id) IS NOT NULL")
    @products = Product.where(dulation_end: rstart..rend, template: false, cancel: nil).where.not(max_bid_id: nil)

    # 落札金額、落札数、入札数
    @sum_max_price   = @products.joins(:max_bid).group("bids.user_id").order("sum_max_price DESC").sum(:max_price)
    @count_max_price = @products.joins(:max_bid).group("bids.user_id").count(:max_price)
    @bids_count      = Bid.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @watches_count   = Watch.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @follows_count   = Follow.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @searches_count  = Search.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count

    @user_ids = (@sum_max_price.keys + @bids_count.keys + @watches_count.keys + @follows_count.keys).uniq

    @users = User.where(id: @user_ids)

    respond_to do |format|
      format.html
      format.csv { export_csv "users_total.csv" }
    end
  end

  private

  def user_params
    # params.require(:user).permit(%w|email password name company tel zip addr_1 addr_2 addr_3 account bank seller charge fax url license business_hours note allow_mail confirmed_at result_message machinelife_company_id header_image|)

    params.require(:user).permit(:email, :password, :name, :company, :tel, :zip, :addr_1, :addr_2, :addr_3, :account,
       :bank, :seller, :charge, :fax, :url, :license, :business_hours, :note, :allow_mail, :confirmed_at,
       :result_message, :machinelife_company_id, :header_image, :remove_header_image, industry_ids: [])
  end

  def password_params
    params.require(:user).permit(%w|password password_confirmation|)
  end
end
