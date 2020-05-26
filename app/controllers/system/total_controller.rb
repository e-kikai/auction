class System::TotalController < System::ApplicationController
  include Exports

   before_action :company_selectors, exsist: [:index]
   before_action :date_selectors,    exsist: [:products_monthly]

  def index
    @companies = User.companies.order(:id)

    respond_to do |format|
      format.html
      format.pdf {
        send_data @render_to_string,
          filename:     "total_#{@date.strftime('%Y%m')}.pdf",
          content_type: "application/pdf",
          disposition:  "inline"
      }
      format.csv { export_csv "total_#{@date.strftime('%Y%m')}.csv" }
    end
  end

  def products
    # 取得
    auto_sql = "DATE(dulation_end) + auto_resale * auto_resale_date"
    # @products  = Product.includes(:user).where(created_at: @date.beginning_of_month..@date.end_of_month, template: false)
    @products = Product.includes(:user).where(template: false)
    @products = @products.where(user: @company) if @company.present? # 会社別

    gro       = "DATE(created_at)"
    gro_end   = "DATE(dulation_end)"

    # 集計
    @start_counts   = @products.group("DATE(dulation_start)").where(@where_str).count
    @end_counts     = @products.where(cancel: nil, max_bid_id: nil).group(gro_end).where(@where_end).count
    @fin_counts     = @products.where(cancel: nil, max_bid_id: nil).group(auto_sql).having("#{auto_sql} BETWEEN ? AND ?", @rstart, @rend).count
    @cancel_counts  = @products.where.not(cancel: nil).where(max_bid_id: nil).group(gro_end).where(@where_end).count
    @success        = @products.where(cancel: nil).where.not(max_bid_id: nil).group(gro_end).where(@where_end)
    @success_counts = @success.count
    @success_prices = @success.sum(:max_price)

    # 入札・ユーザ集計
    @bid_counts          = Bid.where(product_id: @products).where(@where_cr).group(gro).count
    @bid_user_counts     = Bid.where(product_id: @products).where(@where_cr).group(gro).distinct.count(:user_id)
    @bid_user_total      = Bid.where(product_id: @products).where(@where_cr).distinct.count(:user_id)
    @detail_log_counts   = DetailLog.where(product_id: @products).where(@where_cr).group(gro).count
    @detail_user_counts  = DetailLog.where(product_id: @products).where(@where_cr).group(gro).distinct.count(:ip)
    @detail_user_total   = DetailLog.where(product_id: @products).where(@where_cr).distinct.count(:ip)
    @watch_counts        = Watch.where(product_id: @products).where(@where_cr).group(gro).count
    @watch_user_counts   = Watch.where(product_id: @products).where(@where_cr).group(gro).distinct.count(:user_id)
    @watch_user_total    = Watch.where(product_id: @products).where(@where_cr).distinct.count(:user_id)
    @user_counts         = User.group(gro).where(@where_cr).count

    @start_count        = @products.where("dulation_start <= ? AND dulation_end > ?", @rstart, @rstart).count
  end

  def products_monthly
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
    # 期間内に出品されていた商品
    @products = Product.includes(:user).where(template: false)

    # @products = Product.includes(:user, :max_bid).where(template: false).where("dulation_start < ? AND dulation_end > ?", @rend, @rstart)

    @now_count = @products.where("dulation_start < ? AND dulation_end > ?", @rend, @rstart).count

    @success       = @products.where(cancel: nil).where.not(max_bid_id: nil).where(@where_end)
    @success_count = @success.count
    @success_price = @success.sum(:max_price)

    @success_products = @products.where.not(max_bid_id: nil).where("dulation_end < ? ", @rend)
    @max_product      = @success.order("max_price DESC").first
    @max_bid_product  = @success.order("bids_count DESC").first

    @day = @rend.day

    @users = User.where(@where_cr)

    @bid_count = Bid.where(@where_cr).count
    @bid_user  = Bid.where(@where_cr).distinct.count(:user_id)

    @watches  = Watch.where(@where_cr)
    @follows  = Follow.where(@where_cr)
    @searches = Search.where(@where_cr)
  end

  def categories
    @categories   = Category.all.index_by(&:id)

    @products     = Product.where(template: false)

    @now_products = @products.where("dulation_start < ? AND dulation_end > ?", @rend, @rstart)
    @now_counts = @now_products.group(:category_id).count
    @now_companies_counts = @now_products.group(:category_id).count(:user_id)

    @start_counts       = @products.where(@where_str).group(:category_id).count
    @start_companies_counts = @products.where(@where_str).group(:category_id).count(:user_id)

    @success        = @products.where(cancel: nil).where.not(max_bid_id: nil).where(@where_end)
    @success_counts = @success.group(:category_id).count
    @success_prices = @success.group(:category_id).sum(:max_price)


    @bid_counts         = Bid.where(@where_cr).joins(:product).group(:category_id).count
    @bid_user_counts    = Bid.where(@where_cr).joins(:product).group(:category_id).count(:user_id)
    @watch_counts       = Watch.where(@where_cr).joins(:product).group(:category_id).count
    @watch_user_counts  = Watch.where(@where_cr).joins(:product).group(:category_id).count(:user_id)
    @detail_log_counts  = DetailLog.where(@where_cr).joins(:product).group(:category_id).count
    @detail_user_counts = DetailLog.where(@where_cr).joins(:product).group(:category_id).count(:user_id)

    @csort = @categories.keys
  end

  private

  def company_selectors
    @company = params[:company]

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end

  def date_selectors
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Date.today

    @rstart = @date.beginning_of_month
    @rend   = @date.end_of_month

    @where_cr  = {created_at: @rstart..@rend}
    @where_str = {dulation_start: @rstart..@rend}
    @where_end = {dulation_end: @rstart..@rend}
  end
end
