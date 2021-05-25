class System::TotalController < System::ApplicationController
  include Exports

  before_action :company_selectors, exsist: [:index]
  before_action :date_selectors,    exsist: [:products_monthly, :nitamono_monthly]

  def index
    @companies = User.companies.order(:id)

    @product_counts = Product.group(:user_id).where(template: false).count()

    respond_to do |format|
      format.html
      format.pdf {
        send_data render_to_string,
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
    @success_prices = @success_prices.map { |key, val| [key,Product.calc_price_with_tax(val, @date)] }.to_h # 総額対応

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
    @success_prices = @success_prices.map { |key, val| [key,Product.calc_price_with_tax(val, key)] }.to_h # 総額対応

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
    @success_price = Product.calc_price_with_tax(@success_price) # 総額対応

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
    @categories   = Category.all.order(:id).index_by(&:id)
    @counts = {}

    @products     = Product.where(template: false)

    @now_products    = @products.where("dulation_start < ? AND dulation_end > ?", @rend, @rstart)
    @counts[:now]    = @now_products.group(:category_id).order("count_all DESC").count
    @counts[:now_co] = @now_products.group(:category_id).distinct.count(:user_id)
    @now_co_total    = @now_products.distinct.count(:user_id)

    @start_products    = @products.where(@where_str)
    @counts[:start]    = @start_products.group(:category_id).order("count_all DESC").count
    @counts[:start_co] = @start_products.group(:category_id).distinct.count(:user_id)
    @start_co_total    = @start_products.distinct.count(:user_id)

    @success                = @products.where(cancel: nil).where.not(max_bid_id: nil).where(@where_end)
    @counts[:success]       = @success.group(:category_id).order("count_all DESC").count
    @counts[:success_price] = @success.group(:category_id).order("sum_max_price DESC").sum(:max_price)

    @bids              = Bid.where(@where_cr).joins(:product)
    @counts[:bid]      = @bids.group(:category_id).order("count_all DESC").count
    @counts[:bid_user] = @bids.group(:category_id).distinct.count(:user_id)
    @bid_user_total    = @bids.distinct.count(:user_id)

    @watches              = Watch.where(@where_cr).joins(:product)
    @counts[:watch]       = @watches.group(:category_id).order("count_all DESC").count
    @counts[:watch_user]  = @watches.group(:category_id).distinct.count(:user_id)
    @watch_user_total     = @watches.distinct.count(:user_id)

    @detail_logs       = DetailLog.where(@where_cr).joins(:product)
    @counts[:log]      = @detail_logs.group(:category_id).order("count_all DESC").count
    @counts[:log_user] = @detail_logs.group(:category_id).distinct.count(:user_id)
    @log_user_total    = @detail_logs.distinct.count(:user_id)

    @csort = (@counts[:success_price].keys + @counts[:watch].keys + @counts[:log].keys  + @counts[:now].keys + @categories.keys).uniq
    if params[:s].present? && @counts[params[:s].intern].present?
      @csort = (@counts[params[:s].intern].keys + @csort).uniq
    end

    # 項目セレクタ
    @column_selectors = {
      "落札金額"   => :success_price,
      "落札数"     => :success,
      "ウォッチ数" => :watch,
      "詳細閲覧数" => :log,
      "出品件数"   => :now,
      "開始数"     => :start,
    }
  end

  def nitamono
    ### 詳細リンク集計 ###
    detail_logs         = DetailLog.where(@where_cr)

    @detail_log_counts  = detail_logs.group(@group).count
    @detail_user_counts = detail_logs.group(@group).distinct.count(:ip)

    same_categories     = detail_logs.where(r: "dtl_sca")
    @sca_counts         = same_categories.group(@group).count
    @sca_user_counts    = same_categories.group(@group).distinct.count(:ip)

    nitamono_recommends = detail_logs.where(r: "dtl_nmr")
    @nmr_counts         = nitamono_recommends.group(@group).count
    @nmr_user_counts    = nitamono_recommends.group(@group).distinct.count(:ip)

    to_nitamono          = detail_logs.where("r LIKE '%nms%'")
    @to_nms_counts       = to_nitamono.group(@group).count
    @to_nms_user_counts  = to_nitamono.group(@group).distinct.count(:ip)

    ### 似たものサーチコンバージョン取得 ###
    @bids = Bid.where(@where_cr)
      .where("(user_id, product_id) IN (SELECT dl.user_id, dl.product_id FROM detail_logs dl WHERE (dl.r LIKE '%nms%' OR dl.r LIKE '%nmr%'))")
      .group("DATE(bids.created_at)").count

    max_bids = Product.status(Product::STATUS[:mix]).where(@where_end).reorder("").joins(:max_bid)
    .where("(bids.user_id, bids.product_id) IN (SELECT dl.user_id, dl.product_id FROM detail_logs dl WHERE (dl.r LIKE '%nms%' OR dl.r LIKE '%nmr%'))")

    @max_bid_counts = max_bids.group("DATE(products.dulation_end)").count
    @max_bid_prices = max_bids.group("DATE(products.dulation_end)").sum("products.max_price")
    @max_bid_prices = @max_bid_prices.map { |key, val| [key,Product.calc_price_with_tax(val, key)] }.to_h # 総額対応

    @watches = Watch.where(@where_cr)
      .where("(user_id, product_id) IN (SELECT dl.user_id, dl.product_id FROM detail_logs dl WHERE (dl.r LIKE '%nms%' OR dl.r LIKE '%nmr%'))")
      .group("DATE(watches.created_at)").count

    ### 検索集計 ###
    search_logs         = SearchLog.where(@where_cr)

    @search_log_counts  = search_logs.group(@group).count
    @search_user_counts = search_logs.group(@group).distinct.count(:ip)

    nitamono_searches   = search_logs.where.not(nitamono_product_id: nil)
    @nms_counts         = nitamono_searches.group(@group).count
    @nms_user_counts    = nitamono_searches.group(@group).distinct.count(:ip)

    ### 合計人数 ###
    @search_user_total = search_logs.distinct.count(:ip)

    @detail_user_total = detail_logs.distinct.count(:ip)
    @nms_user_total    = nitamono_searches.distinct.count(:ip)
    @sca_user_total    = same_categories.distinct.count(:ip)
    @nmr_user_total    = nitamono_recommends.distinct.count(:ip)
    @to_nms_user_total = to_nitamono.distinct.count(:ip)


    respond_to do |format|
      format.html
      format.csv { export_csv "nitamono_total_#{params[:range]}_#{Time.now.strftime('%Y%m%d')}.csv" }
    end
  end

  ### VBPR・オススメ集計 ###
  def osusume
    ### 詳細リンク集計 ###
    dls = DetailLog.where(@where_cr).group(@group) # base

    @dl_counts = dls.count               # 総数
    @dl_ips    = dls.where.not(ip: nil).distinct.count(:ip) # 総IP数
    @dl_users  = dls.where.not(user_id: nil).distinct.count(:user_id) # 総人数

    vbpr = dls.where.not(user_id: nil).where("r LIKE '%vos%'") #VBPR
    @vbpr_counts = vbpr.count
    @vbpr_users  = vbpr.distinct.count(:user_id)

    watches = dls.where.not(user_id: nil).where("r LIKE '%waos%'") # ウォッチオススメ
    @watch_counts = watches.count
    @watch_users  = watches.distinct.count(:user_id)

    bids = dls.where.not(user_id: nil).where("r LIKE '%wbios%'") # 入札オススメ
    @bid_counts = bids.count
    @bid_users  = bids.distinct.count(:user_id)

    cart = dls.where.not(user_id: nil).where("r LIKE '%crt%'") # 入札してみませんか？
    @cart_counts = cart.count
    @cart_users  = cart.distinct.count(:user_id)

    nxt = dls.where.not(user_id: nil).where("r LIKE '%nxt%'") # こちらもいかがでしょう
    @nxt_counts = nxt.count
    @nxt_users  = nxt.distinct.count(:user_id)

    often = dls.where.not(user_id: nil).where("r ~ '(onew|mnw)'") # よくアクセスするカテゴリの新着
    @often_counts = often.count
    @often_users  = often.distinct.count(:user_id)

    endo = dls.where.not(ip: nil).where("r LIKE '%endo%'") # まもなく終了
    @endo_counts = endo.count
    @endo_ips    = endo.distinct.count(:ip)

    tnew = dls.where.not(ip: nil).where("r LIKE '%tnew%'") # 工具新着
    @tnew_counts = tnew.count
    @tnew_ips    = tnew.distinct.count(:ip)

    mnew = dls.where.not(ip: nil).where("r LIKE '%mnew%'") # 機械新着
    @mnew_counts = mnew.count
    @mnew_ips    = mnew.distinct.count(:ip)

    zero = dls.where.not(ip: nil).where("r LIKE '%zer%'") # こんなのもあります
    @zero_counts = zero.count
    @zero_ips    = zero.distinct.count(:ip)

    check = dls.where.not(ip: nil).where("r LIKE '%chk%'") # 最近チェックした商品
    @check_counts = check.count
    @check_ips    = check.distinct.count(:ip)

    dlos = dls.where.not(ip: nil).where("r LIKE '%dlos%'") # 閲覧履歴に基づくオススメ
    @dlos_counts = dlos.count
    @dlos_ips    = dlos.distinct.count(:ip)

    follow = dls.where("r LIKE '%fls%'") # フォロー新着
    @follow_counts = follow.count
    @follow_users  = follow.distinct.count(:user_id)

    ### 従来のアクセス ###
    same_categories = dls.where("r LIKE '%sca%'")
    @sca_counts = same_categories.count
    @sca_ips    = same_categories.distinct.count(:ip)

    nitamono_recommends = dls.where("r LIKE '%nmr%'")
    @nmr_counts = nitamono_recommends.count
    @nmr_ips    = nitamono_recommends.distinct.count(:ip)

    to_nitamono = dls.where("r LIKE '%nms%'")
    @to_nms_counts = to_nitamono.count
    @to_nms_ips    = to_nitamono.distinct.count(:ip)

    mail = dls.where("r LIKE '%mail_%'")
    @mail_counts = mail.count
    @mail_ips    = mail.distinct.count(:ip)

    # mailchimp = dls.where("r LIKE '%mailchimp%'")
    # @mailchimp_counts = mailchimp.count
    # @mailchimp_ips    = mailchimp.distinct.count(:ip)

    search = dls.where("r LIKE '%src%'")
    @search_counts = search.count
    @search_ips    = search.distinct.count(:ip)

    ml = dls.where("r LIKE '%machinelife%'")
    @ml_counts = ml.count
    @ml_ips    = ml.distinct.count(:ip)

    ekikai = dls.where("r LIKE '%ekikai%'")
    @ekikai_counts = ekikai.count
    @ekikai_ips    = ekikai.distinct.count(:ip)

    google = dls.where("referer ~ '(google|yahoo|bing|baidu)'")
    @google_counts = google.count
    @google_ips    = google.distinct.count(:ip)

    ### 詳細 ###
    dls_us = dls.where.not(user_id: nil)

    @top_vbpr = dls_us.where("r LIKE '%top_vos%'").count
    @dtl_vbpr = dls_us.where("r LIKE '%dtl_vos%'").count
    @top_watch = dls_us.where("r LIKE '%top_waos%'").count
    @dtl_watch = dls_us.where("r LIKE '%dtl_waos%'").count
    @top_bid = dls_us.where("r LIKE '%top_bios%'").count
    @dtl_bid = dls_us.where("r LIKE '%dtl_bios%'").count
    @top_cart = dls_us.where("r LIKE '%top_crt%'").count
    @dtl_cart = dls_us.where("r LIKE '%dtl_crt%'").count
    @top_nxt = dls_us.where("r LIKE '%top_nxt%'").count
    @dtl_nxt = dls_us.where("r LIKE '%dtl_nxt%'").count
    @top_often = dls_us.where("r ~ 'top_(onew|mnw)'").count
    @dtl_often = dls_us.where("r ~ 'dtl_(onew|mnw)'").count

    @top_follow = dls_us.where("r LIKE '%top_fls%'").count

    dls_ip = dls.where.not(ip: nil)
    @top_dl = dls_us.where("r LIKE '%top%'").count
    @dtl_dl = dls_us.where("r LIKE '%dtl%'").count

    @top_endo = dls_ip.where("r LIKE '%top_endo%'").count
    @dtl_endo = dls_ip.where("r LIKE '%dtl_endo%'").count
    @top_tnew = dls_ip.where("r LIKE '%top_tnew%'").count
    @dtl_tnew = dls_ip.where("r LIKE '%dtl_tnew%'").count
    @top_mnew = dls_ip.where("r LIKE '%top_mnew%'").count
    @dtl_mnew = dls_ip.where("r LIKE '%dtl_mnew%'").count
    @top_zero = dls_ip.where("r LIKE '%top_zer%'").count
    @dtl_zero = dls_ip.where("r LIKE '%dtl_zer%'").count
    @top_check = dls_ip.where("r LIKE '%top_chk%'").count
    @dtl_check = dls_ip.where("r LIKE '%dtl_chk%'").count
    @top_dlos = dls_ip.where("r LIKE '%top_dlos%'").count
    @dtl_dlos = dls_ip.where("r LIKE '%dtl_dlos%'").count

    respond_to do |format|
      format.html {
        render template: :osusume_user if params[:user]
      }
      format.csv { export_csv "osusume_total_#{params[:range]}_#{Time.now.strftime('%Y%m%d')}.csv" }
    end
  end

  private

  def company_selectors
    @company = params[:company]

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end

  def date_selectors
    # 取得範囲(全取得対応)
    case params[:range]
    when "all"
      @date = Date.today

      @rstart = Date.new(2018, 3, 1)
      @rend   = Product.maximum(:dulation_end)

      @group  = "DATE(created_at)"
      @rows   = @rstart.to_date..@rend.to_date

    when "monthly"
      @date = Date.today

      @rstart = Date.new(2018, 3, 1)
      @rend   = Product.maximum(:dulation_end)

      @group  = "to_char(created_at, 'YYYY/MM')"
      @rows   = (@rstart..@rend).select{ |date| date.day == 1}.map { |d| d.strftime('%Y/%m')}

    else # daily
      @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Date.today

      @rstart = @date.to_time.beginning_of_month
      @rend   = @date.to_time.end_of_month

      @group  = "DATE(created_at)"
      @rows   = @date.beginning_of_month..@date.end_of_month
    end

    @rrange = @rstart..@rend

    # @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Date.today
    #
    # @rstart = @date.to_time.beginning_of_month
    # @rend   = @date.to_time.end_of_month

    @where_cr  = {created_at: @rrange}
    @where_str = {dulation_start: @rrange}
    @where_end = {dulation_end: @rrange}
  end
end
