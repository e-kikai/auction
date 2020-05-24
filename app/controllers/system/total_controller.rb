class System::TotalController < System::ApplicationController
  include Exports

   before_action :company_selectors

  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

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
    @products = Product.includes(:user).where(template: false)
    @products = @products.where(user: @company) if @company.present?

    # 集計
    @start_counts   = @products.group("DATE(dulation_start)").having("DATE(dulation_start) BETWEEN ? AND ?", rstart, rend).count
    @end_counts     = @products.where(cancel: nil, max_bid_id: nil).group(auto_sql).having("#{auto_sql} BETWEEN ? AND ?", rstart, rend).count
    @cancel_counts  = @products.where.not(cancel: nil).where(max_bid_id: nil).group("DATE(dulation_end)").having("DATE(dulation_end) BETWEEN ? AND ?", rstart, rend).count

    @success        = @products.where(cancel: nil).where.not(max_bid_id: nil).group("DATE(dulation_end)").having("DATE(dulation_end) BETWEEN ? AND ?", rstart, rend)
    @success_counts = @success.count
    @success_prices = @success.sum(:max_price)

    if @company.present?
      product_ids = @products.select(:id)

      bids        = Bid.where(product_id: product_ids)
      detail_logs = DetailLog.where(product_id: product_ids)
      watches     = Watch.where(product_id: product_ids)
    else
      bids        = Bid.all
      detail_logs = DetailLog.all
      watches     = Watch.all
    end

    @bid_counts         = bids.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    @detail_log_counts  = detail_logs.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    @watch_counts       = watches.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count

    @user_counts        = User.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count

    # @start_count        = @products.where("dulation_start < ?", rstart).where("(max_bid_id IS NOT NULL AND dulation_end >= ?) OR (max_bid_id IS NULL)", rstart).count
    @start_count        = @products.where("dulation_start <= ? AND dulation_end > ?", rstart, rstart).count

    @detail_user_counts = detail_logs.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count("DISTINCT ip")
  end

  def products_monthly
    @company = params[:company]

    @products = Product.includes(:user).where(template: false)
    @products = @products.where(user: @company) if @company.present? # 会社別


    endd = Product.maximum(:dulation_end)
    @monthes = (Date.new(2018, 3, 1) .. endd).select{|date| date.day == 1}.map { |d| d.strftime('%Y/%m')}

    # 商品集計
    gro_sta = "to_char(dulation_start, 'YYYY/MM')"
    gro_end = "to_char(dulation_end, 'YYYY/MM')"
    gro     = "to_char(created_at, 'YYYY/MM')"

    @start_counts   = @products.group(gro_sta).order("to_char_dulation_start_yyyy_mm").count
    @end_counts     = @products.where(cancel: nil, max_bid_id: nil).group(gro_end).count
    @cancel_counts  = @products.where.not(cancel: nil).group(gro_end).count
    @success        = @products.where(cancel: nil).where.not(max_bid_id: nil).group(gro_end)
    @success_counts = @success.count
    @success_prices = @success.sum(:max_price)

    # 入札・ユーザ集計
    @bid_counts          = Bid.where(product_id: @products).group(gro).count
    @bid_user_counts     = Bid.where(product_id: @products).group(gro).distinct.count(:user_id)
    @detail_log_counts   = DetailLog.where(product_id: @products).group(gro).count
    @detail_user_counts  = DetailLog.where(product_id: @products).group(gro).distinct.count(:ip)
    @watch_counts        = Watch.where(product_id: @products).group(gro).count
    @watch_user_counts   = Watch.where(product_id: @products).group(gro).distinct.count(:user_id)
    @user_counts         = User.group(gro).count

    @start_count        = 0
  end

  def formula
    @date    = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @company = params[:company]

    # 取得
    rstart = @date.beginning_of_month
    rend   = @date.end_of_month

    # 期間内に出品されていた商品
    @products = Product.includes(:user, :max_bid).where(template: false, cancel: nil).where("dulation_start < ? AND dulation_end > ?", rend, rstart)

    @success_products = @products.where.not(max_bid_id: nil).where("dulation_end < ? ", rend)
    @max_product      = @success_products.order("max_price DESC").first
    @max_bid_product  = @success_products.order("bids_count DESC").first

    @day = rend.day

    @users = User.where(created_at: rstart..rend)

    @bids = Bid.where(product_id:  @success_products)

    @watches  = Watch.where(created_at: rstart..rend)
    @follows  = Follow.where(created_at: rstart..rend)
    @searches = Search.where(created_at: rstart..rend)
  end

  private

  def company_selectors
    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end
end
