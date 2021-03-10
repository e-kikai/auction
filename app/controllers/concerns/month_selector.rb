module MonthSelector
  extend ActiveSupport::Concern

  ### 管理者ページの期間選択共通部分 ###
  def month_selector
    # 取得範囲(全取得対応)
    case params[:range]


    when "month"
      @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Date.today

      @rstart = @date.to_time.beginning_of_month
      @rend   = @date.to_time.end_of_month

      @group  = "DATE(created_at)"
      @rows   = @date.beginning_of_month..@date.end_of_month
    # when "all"
    else
      @date = Date.today

      @rstart = Date.new(2018, 3, 1).beginning_of_day
      # @rend   = Product.maximum(:dulation_end)
      @rend   = Date.today.end_of_day

      @group  = "DATE(created_at)"
      @rows   = @rstart.to_date..@rend.to_date
    end

    @rrange = @rstart..@rend

    # @where_cr  = {created_at: @rrange}
    # @where_str = {dulation_start: @rrange}
    # @where_end = {dulation_end: @rrange}
  end
end
