class Myauction::TotalController < Myauction::ApplicationController
  before_action :check_seller

  def products
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now.to_date
    @mine = params[:mine]

    # # 取得
    # rstart = @date.beginning_of_month
    # rend   = @date.end_of_month
    # auto_sql = "DATE(dulation_end) + auto_resale * auto_resale_date"
    # # @products  = Product.includes(:user).where(created_at: @date.beginning_of_month..@date.end_of_month, template: false)
    # @products = Product.includes(:user).where(template: false)
    # @products = @products.where(user: current_user) if @mine.present?
    #
    # # 集計
    # @start_counts   = @products.group("DATE(dulation_start)").having("DATE(dulation_start) BETWEEN ? AND ?", rstart, rend).count
    # @end_counts     = @products.where(cancel: nil, max_bid_id: nil).group(auto_sql).having("#{auto_sql} BETWEEN ? AND ?", rstart, rend).count
    # @cancel_counts  = @products.where.not(cancel: nil).where(max_bid_id: nil).group("DATE(dulation_end)").having("DATE(dulation_end) BETWEEN ? AND ?", rstart, rend).count
    #
    # @success        = @products.where(cancel: nil).where.not(max_bid_id: nil).group("DATE(dulation_end)").having("DATE(dulation_end) BETWEEN ? AND ?", rstart, rend)
    # @success_counts = @success.count
    # @success_prices = @success.sum(:max_price)
    #
    # if @mine.present?
    #   product_ids = @products.select(:id)
    #
    #   bids        = Bid.where(product_id: product_ids)
    #   detail_logs = DetailLog.where(product_id: product_ids)
    #   watches     = Watch.where(product_id: product_ids)
    # else
    #   bids        = Bid.all
    #   detail_logs = DetailLog.all
    #   watches     = Watch.all
    # end
    #
    # @bid_counts        = bids.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    # @detail_log_counts = detail_logs.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    # @detail_user_counts = detail_logs.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count("DISTINCT ip")
    #
    # @watch_counts      = watches.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    #
    # @user_counts       = User.group("DATE(created_at)").having("DATE(created_at) BETWEEN ? AND ?", rstart, rend).count
    #
    # # @start_count    = @products.where(cancel: nil).where("dulation_start < ?", rstart).where("(max_bid_id IS NOT NULL AND dulation_end >= ?) OR (max_bid_id IS NULL AND #{auto_sql} >=?)", rstart, rstart).count
    # @start_count        = @products.where("dulation_start <= ? AND dulation_end > ?", rstart, rstart).count

    @rstart = @date.to_time.beginning_of_month
    @rend   = @date.to_time.end_of_month

    @where_cr  = {created_at: @rstart..@rend}
    @where_str = {dulation_start: @rstart..@rend}
    @where_end = {dulation_end: @rstart..@rend}

    # 取得
    auto_sql = "DATE(dulation_end) + auto_resale * auto_resale_date"
    @products = Product.includes(:user).where(template: false)
    @products = @products.where(user: current_user) if @mine.present?

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


end
