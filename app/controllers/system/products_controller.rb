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

    @products  = Product.status(params[:cond]).includes(:product_images, :user).where(dulation_end: @date.all_day, template: false, cancel: nil).where.not(max_bid_id: nil).order(dulation_end: :desc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end
end
