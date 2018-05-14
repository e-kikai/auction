class System::ProductsController < System::ApplicationController
  def index
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @company = params[:company]

    @products  = Product.includes(:product_images, :user).where(created_at: @date.beginning_of_month..@date.end_of_month, template: false).order(created_at: :desc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    @company_selectors = User.companies.map { |co| [co.company_remove_kabu, co.id] }

  end
end
