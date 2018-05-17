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
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now.to_date
    @company = params[:company]

    # 取得
    rstart = @date.beginning_of_month
    rend   = @date.end_of_month
    auto_sql = "DATE(dulation_end) + auto_resale * auto_resale_date"
    # @products  = Product.includes(:user).where(created_at: @date.beginning_of_month..@date.end_of_month, template: false)
    @products  = Product.includes(:user).where(template: false)
    @products = @products.where(user: @company) if @company.present?

    # 集計
    @start_counts   = @products.group("DATE(dulation_start)").having("DATE(dulation_start) BETWEEN ? AND ?", rstart, rend).count
    @end_counts     = @products.where(max_bid_id: nil).group(auto_sql).having("#{auto_sql} BETWEEN ? AND ?", rstart, rend).count

    @success        = @products.where.not(max_bid_id: nil).group("DATE(dulation_end)").having("DATE(dulation_end) BETWEEN ? AND ?", rstart, rend)
    @success_counts = @success.count
    @success_prices = @success.sum(:max_price)

    @bid_counts     = Bid.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count

    @detail_log_counts = DetailLog.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    @watch_counts      = Watch.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    @user_counts       = User.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count

    @start_count    = @products.where("dulation_start < ?", rstart).where("(max_bid_id IS NOT NULL AND dulation_end >= ?) OR (max_bid_id IS NULL AND #{auto_sql} >=?)", rstart, rstart).count

    # セレクタ
    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end
end
