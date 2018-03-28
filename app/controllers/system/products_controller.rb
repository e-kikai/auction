class System::ProductsController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @products  = Product.includes(:product_images, :user).where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)
    @pproducts = @products.page(params[:page]).per(200)
  end
end
