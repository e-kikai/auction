class System::ProductsController < System::ApplicationController
  include Exports

  before_action :company_selectors, exsist: [:image, :all_process_vector]
  before_action :date_selectors,    exsist: [:products_monthly, :all_process_vector]

  def index
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @products  = Product.includes(:product_images, :user).where(created_at: @date.all_month, template: false).order(created_at: :desc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "products_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

  def finished
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    @cond    = params[:cond]

    @products  = Product.includes(:product_images, :user).where(dulation_end: @date.all_day, template: false).order(dulation_end: :desc)

    @products = case @cond
    when "1"; @products.where(max_bid_id: nil, cancel: nil, auto_resale: 0)
    when "3"; @products.where.not(cancel: nil)
    else;     @products.where(cancel: nil).where.not(max_bid_id: nil)
    end

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "finished_month_#{@date.strftime('%Y_%m_%d')}.csv" }
    end
  end

  def finished_month
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @cond    = params[:cond]

    @products  = Product.includes(:product_images, :user).where(dulation_end: @date.all_month, template: false).order(dulation_end: :desc)

    @products = case @cond
    when "1"; @products.where(max_bid_id: nil, cancel: nil, auto_resale: 0)
    when "3"; @products.where.not(cancel: nil)
    else;     @products.where(cancel: nil).where.not(max_bid_id: nil)
    end

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "finished_month_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

  def results
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @products  = Product.includes(:product_images, :user, :category, max_bid: :user).where(template: false)
      .where("dulation_start <= ? AND dulation_end >= ?", @date.end_of_month, @date.beginning_of_month).order(dulation_start: :asc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "results_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

  def image
    @products = Product.where(template: false).reject { |pr| pr.thumb_url == "noimage.png" }
    respond_to do |format|
      format.csv { export_csv "products_image_#{Time.now.strftime('%Y%m%d')}.csv" }
    end
  end

  def all_process_vector
    @products = Product.joins(:product_images).includes(:product_images).where(template: false).each { |pr| pr.process_vector }

    redirect_to "/system/", notice: "すべての画像特徴ベクトル変換処理を行いました"

  end

  private

  def company_selectors
    @company = params[:company]

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end

  def date_selectors
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Date.today

    @rstart = @date.to_time.beginning_of_month
    @rend   = @date.to_time.end_of_month

    @where_cr  = {created_at: @rstart..@rend}
    @where_str = {dulation_start: @rstart..@rend}
    @where_end = {dulation_end: @rstart..@rend}
  end
end
