class System::TotalController < System::ApplicationController
  include Exports

  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @companies = User.companies.order(:id)

    respond_to do |format|
      format.html
      format.pdf {
        send_data render_to_string,
          filename:     "total_#{@date.strftime('%Y%m')}.pdf",
          content_type: "application/pdf",
          disposition:  "inline"
      }
      format.csv { export_csv "total.csv" }
    end
  end

  def products
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @company = params[:company]

    # 取得
    @products  = Product.includes(:product_images, :user).where(created_at: @date.beginning_of_month..@date.end_of_month, template: false).order(created_at: :desc)

    @products = @products.where(user: @company) if @company.present?

    @pproducts = @products.page(params[:page]).per(100)

    # セレクタ
    @company_selectors = User.companies.pluck(:company, :id)
  end
end
