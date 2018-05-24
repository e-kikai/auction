class System::ProductsController < System::ApplicationController
  def index
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @company = params[:company]

    @products  = Product.includes(:product_images, :user).where(created_at: @date.all_month, template: false).order(created_at: :desc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end

  def finished
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    @company = params[:company]
    @cond    = params[:cond]

    @products  = Product.includes(:product_images, :user).where(dulation_end: @date.all_day, template: false).order(dulation_end: :desc)

    @products = case @cond
    when "1"
      @products.where(max_bid_id: nil, cancel: nil)
    when "3"
      @products.where.not(cancel: nil)
    else
      @products.where.not(max_bid_id: nil)
    end

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end
end
