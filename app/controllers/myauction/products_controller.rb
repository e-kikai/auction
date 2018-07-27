class Myauction::ProductsController < Myauction::ApplicationController
  before_action :check_seller
  before_action :get_product, only: [:edit, :update, :destroy, :prompt, :cancel, :additional, :additional_update]

  def index
    @search    = current_user.products.includes(:product_images, max_bid: :user).search(params[:q])

    @products  = @search.result.status(params[:cond])

    if params[:cond] == "3" && params[:all].blank?
      in_codes  = current_user.products.where(cancel: nil).where.not(code: "").select(:code)
      @products = @products.where.not(code: in_codes)
    elsif params[:cond] == "2"
      @user_selectors = current_user.products.status(params[:cond]).joins(max_bid: :user).reorder(nil)
        .group("bids.user_id", "users.account", "users.name", "users.company").count
        .map { |k, v| ["#{k[1]} | #{k[2]} #{k[3]} (#{v})", k[0]] }

      @products = @products.joins(:max_bid).where("bids.user_id" => params[:user_id]) if params[:user_id].present?
    elsif params[:cond] == "-1"
      @start_date_selector = current_user.products.status(params[:cond]).reorder(nil)
        .group("DATE(dulation_start)").count
        .map { |k, v| ["#{k} (#{v})", k] }

      if params[:start_date].present?
        date = Date.strptime(params[:start_date], '%Y/%m/%d')
        @products = @products.where(dulation_start: date.all_day)
      end
    end

    @pproducts = @products.page(params[:page])
  end

  def new
    @product = if params[:template_id].present?
      current_user.products.templates.find(params[:template_id]).dup_init(true)
    elsif params[:id].present?
      current_user.products.find(params[:id]).dup_init(false)
    else
      current_user.products.new
    end

    # マシンライフから出品
    if params[:machinelife_id].present?
      begin
        @url   = "#{Product::MACHINELIFE_CRAWL_URL}?t=auction_machine&id=#{params[:machinelife_id].to_i}"
        json   = open(@url).read
        @data = ActiveSupport::JSON.decode json

        @product.attributes = {
          machinelife_id: @data["id"],
          code:           @data["no"],
          name:           @data["name"],
          description:    @data["spec"],
          youtube:        @data["youtube"],
        }

        @data["images"].split.each do |img|
          @product.product_images.new.remote_image_url = "#{Product::MACHINELIFE_MEDIA_PASS}#{img}"
        end

        session[:m2a_template_id] = params[:template_id]
      rescue
        redirect_to "/myauction/", alert: "マシンライフから商品情報を取得できませんでした"
      end
    end
  end

  # def confirm
  #   @product = current_user.products.new(product_params)
  #   render :new if @product.invalid?
  # end

  def create
    @product = current_user.products.new(product_params)
    params[:images].each { |img| @product.product_images.new(image: img) } if params[:images].present?

    # if params[:back]
    #   render :new
    # elsif @product.save
    if @product.save
      redirect_to "/myauction/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    params[:images].each { |img| @product.product_images.new(image: img) } if params[:images].present?

    cond = @product.dulation_start > Time.now ? 0 : 1
    if @product.update(product_params)
      if cond < 1
        redirect_to "/myauction/products?cond=-1", notice: "#{@product.name}を変更しました"
      else
        redirect_to "/myauction/products?cond=1", notice: "#{@product.name}を再出品しました"
      end
    else
      render :edit
    end
  end

  def destroy
    @product.soft_destroy!
    redirect_to "/myauction/products/", notice: "#{@product.name}を削除しました"
  end

  # # 自社即決
  # def prompt
  #   @bid = @product.bids.new(user: current_user, amount: @product.prompt_dicision_price)
  #
  #   if @bid.save
  #     redirect_to "/myauction/products", notice: "#{@product.name}を即決価格で自社入札しました"
  #   else
  #     redirect_to "/myauction/products", alert: "#{@product.name}を即決価格できませんでした"
  #   end
  # end

  # 出品キャンセル
  def cancel
    if params[:product][:cancel].blank?
      redirect_to "/myauction/products", alert: "キャンセル理由を記入してください"
    elsif @product.update(cancel: params[:product][:cancel], dulation_end: Time.now)

      @product.bid_users.each do |us|
        BidMailer.cancel_user(us, @product).deliver
      end
      redirect_to "/myauction/products", notice: "#{@product.name}を出品キャンセルしました"
    else
      redirect_to "/myauction/products", alert: "#{@product.name}を出品キャンセルできませんでした(キャンセルから再出品した商品は、別のキャンセル理由の文言を記述してください)"
    end
  end

  # マシンライフからオークションへ
  def m2a
    # 日付
    # @date = case
    # when params[:date];      Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
    # when session[:m2a_date]; session[:m2a_date]
    # else;                    Time.now
    # end

    @date = case
    when params[:date].present?;                  params[:date]
    when session[:m2a_date] && params[:s].blank?; session[:m2a_date]
    else;                                         nil
    end
    session[:m2a_date] = @date

    if @date.present?
      date       = DateTime.parse("#{@date}/1")
      start_date = date.beginning_of_month.strftime("%Y-%m-%d")
      end_date   = date.end_of_month.strftime("%Y-%m-%d")
    end

    # ジャンル
    @genre = case
    when params[:genre].present?;                  params[:genre]
    when session[:m2a_genre] && params[:s].blank?; session[:m2a_genre]
    else;                                          nil
    end

    session[:m2a_genre] = @genre

    # マシンライフからJSONデータを取得
    if current_user.machinelife_company_id.blank?
      redirect_to "/myauction/", alert: "マシンライフ連動IDが設定されていません"
      return
    end

    # ジャンルJSON
    url     = "#{Product::MACHINELIFE_CRAWL_URL}?t=auction_genres&c=#{current_user.machinelife_company_id}"
    json    = open(url).read
    @genres = ActiveSupport::JSON.decode json rescue raise json
    @genre_selectors = @genres.map { |ge| ["#{ge["large_genre"]} (#{ge["count"]})", ge["id"]] }

    # 機械情報JSON
    if @date.present? || @genre.present?
      url    = "#{Product::MACHINELIFE_CRAWL_URL}?t=auction_machines&c=#{current_user.machinelife_company_id}&large_genre_id=#{@genre}&start_date=#{start_date}&end_date=#{end_date}"
      json   = open(url).read
      @datas = ActiveSupport::JSON.decode json rescue raise json
    end

    @date_selector = Time.now.year.downto(2011).sum { |y| 12.downto(1).map { |m| "#{y}/#{m}" } }

    @template_selectors  = current_user.products.templates.pluck(:name, :id)

    @current_machinelife_ids = current_user.products.where.not(machinelife_id: nil).pluck(:machinelife_id)
  end

  def additional
  end

  def additional_update
    if @product.update(additional_params)
      redirect_to "/myauction/products", notice: "#{@product.name}の追記を変更しました"
    else
      render :edit
    end
  end

  private

  def get_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:category_id, :code, :name, :description, :note,
      :dulation_start, :dulation_end, :start_price, :prompt_dicision_price, :lower_price, :youtube,
      :shipping_user, :shipping_comment, :international, :packing, :state, :state_comment, :returns, :returns_comment, :early_termination, :auto_extension, :auto_resale, :auto_resale_date, :shipping_no, :template_id, :hashtags,:addr_1, :addr_2, :delivery_date, :machinelife_id,
      product_images_attributes: [:id, :image, :remote_image_url, :_destroy])
  end

  def additional_params
    params.require(:product).permit(:category_id, :code, :additional, :hashtags, :youtube, :auto_resale, :auto_resale_date)
  end
end
