class System::UsersController < System::ApplicationController
  include Exports

  def index
    @search = User.search(params[:q])

    @users  = @search.result.order(created_at: :desc).includes(:industries)
    @pusers = @users.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv {
        @users = User.where(allow_mail: true)
        export_csv "mailaddress_list.csv"
      }
    end
  end

  def new
    @user = User.new
    @user.confirmed_at = Time.now
  end

  def create
    @user = User.new(user_params)
    @user.skip_confirmation!

    if @user.save
      q = @user.seller? ? "?q[seller_eq]=true" : ""
      redirect_to "/system/users/#{q}", notice: "#{@user.name}を登録しました"
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
      q = @user.seller? ? "?q[seller_eq]=true" : ""
      redirect_to "/system/users/#{q}", notice: "#{@user.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.soft_destroy!

    q = @user.seller? ? "?q[seller_eq]=true" : ""
    redirect_to "/system/users/#{q}", notice: "#{@user.name}を削除しました"
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
      q = @user.seller? ? "?q[seller_eq]=true" : ""
      redirect_to "/system/users/#{q}", notice: "#{@user.name}をのパスワード変更しました"
    else
      render :edit_password
    end
  end


  def total
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    # 取得範囲(全取得対応)
    if params[:all].present?
      rstart = Time.new(2018, 1, 1)
      rend   = Float::INFINITY
    else
      rstart = @date.beginning_of_month
      rend   = @date.end_of_month
    end

    # @users = User.includes(:bids).where("created_at <= ?", rend).where("count(bids.id) IS NOT NULL")
    @products = Product.where(dulation_end: rstart..rend, template: false, cancel: nil).where.not(max_bid_id: nil)

    # 落札金額、落札数、入札数
    @sum_max_price   = @products.joins(:max_bid).group("bids.user_id").order("sum_max_price DESC").sum(:max_price)
    @sum_max_price   = @sum_max_price.map { |key, val| [key,Product.calc_price_with_tax(val, @date)] }.to_h # 総額対応

    @count_max_price = @products.joins(:max_bid).group("bids.user_id").count(:max_price)
    @bids_count      = Bid.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @watches_count   = Watch.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @follows_count   = Follow.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @searches_count  = Search.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count
    @detail_count    = DetailLog.where(created_at: rstart..rend).group(:user_id).order("count_all DESC").count

    @user_ids = (@sum_max_price.keys + @bids_count.keys + @watches_count.keys + @searches_count.keys + @follows_count.keys + @detail_count.keys).uniq

    @users = User.where(id: @user_ids)

    # アクセス取得
    where_ref  = "(referer NOT LIKE 'https://www.mnok.net%' OR referer LIKE 'https://www.mnok.net/products/ads%')"
    where_date = ["created_at BETWEEN ? AND ?", rstart, rend]
    group_by   = [:user_id, :referer, :r]

    @detail_logs  = DetailLog.where(where_date).where(where_ref).where.not(user_id: nil).group(group_by).count()
    @toppage_logs = ToppageLog.where(where_date).where(where_ref).where.not(user_id: nil).group(group_by).count()

    @columns_ekikai = %w|マシンライフ 全機連 e-kikai 電子入札システム DST| # e-kikaiサイト郡
    @columns_ads    = %w|マシンライフ e-kikai| # 広告枠
    @columns_search = %w|Google Yahoo bing 百度| # 検索
    @columns_sns    = %w|Twitter FB YouTube| # SNS

    @sellers_url = User.where(seller: true).where.not(url: "").pluck(:url) # 出品会社サイト
    @urls = @sellers_url.map { |url| url =~ /\/\/(.*?)(\/|$)/ ? $1 : nil }.compact
    @urls << "kkmt.co.jp"

    @total = Hash.new()
    @user_ids.each do |user|
      @total[user] = {
        search:      0,
        sns:         0,
        ads:         0,
        ekikai:      0,
        sellers:     0,
        others:      0,
        google_ads:  0,
        mailchimp:   0,
        mail:        0,
        unknown:     0,
        others_urls: [],
      }
    end

    logs = @detail_logs.merge(@toppage_logs)

    logs.each do |keys, val|
      li   = DetailLog.link_source(keys[2], keys[1])
      user = keys[0]

      next unless @total[user]

      if li =~ Regexp.new(@columns_search.join('|'))
        # 検索
        @total[user][:search] += val
      elsif li =~ Regexp.new(@columns_sns.join('|'))
        # SNS
        @total[user][:sns] += val
      elsif li.include?("ads")
        # 相互枠
        @total[user][:ads] += val
      elsif li.include?("Mailchimp")
        # Mailchimp
        @total[user][:mailchimp] += val
      elsif li.include?("メール")
        # 新着ほかメール
        @total[user][:mail] += val
      elsif li.include?("広告")
        # 広告
        @total[user][:google_ads] += val
      elsif li.include?("(不明)")
        # 不明
        @total[user][:unknown] += val
      elsif li.in?(@urls)
        # 出品会社サイト
        @total[user][:sellers] += val
      elsif li =~ Regexp.new(@columns_ekikai.join('|'))
        # e-kikai
        @total[user][:ekikai] += val
      elsif keys[1] !~ /mnok\.net/
        # その他
        @total[user][:others_urls] << keys[1]
        @total[user][:others] += val
      end
    end

    respond_to do |format|
      format.html
      format.csv { export_csv "users_total.csv" }
    end
  end

  private

  def user_params
    # params.require(:user).permit(%w|email password name company tel zip addr_1 addr_2 addr_3 account bank seller charge fax url license business_hours note allow_mail confirmed_at result_message machinelife_company_id header_image|)

    params.require(:user).permit(:email, :password, :name, :company, :tel, :zip, :addr_1, :addr_2, :addr_3, :account,
       :bank, :seller, :special, :charge, :fax, :url, :license, :business_hours, :note, :allow_mail, :confirmed_at,
       :result_message, :machinelife_company_id, :header_image, :remove_header_image, industry_ids: [])
  end

  def password_params
    params.require(:user).permit(%w|password password_confirmation|)
  end
end
