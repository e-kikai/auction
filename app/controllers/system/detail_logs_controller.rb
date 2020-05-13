class System::DetailLogsController < System::ApplicationController
  include Exports

  def index
    # @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    # @detail_logs  = DetailLog.includes(:product, :user).where(created_at: @date.beginning_of_day..@date.end_of_day).order(created_at: :desc)

    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @detail_logs  = DetailLog.includes(:product, :user).where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)


    respond_to do |format|
      format.html {
        @pdetail_logs = @detail_logs.page(params[:page]).per(500)
      }

      format.csv { export_csv "detail_logs.csv" }
    end
  end

  def monthly
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now.to_date

    days          = @date.beginning_of_month..@date.end_of_month
    where_date    = {created_at: days}
    where_referer = "referer NOT LIKE 'https://www.mnok.net%'"
    group_by      = ["DATE(created_at)", :referer]

    @detail_logs  = DetailLog.where(where_date, where_referer).group(group_by).count()
    @toppage_logs = ToppageLog.where(where_date, where_referer).group(group_by).count()

    @columns = %w|Google Yahoo Twitter Facebook bing YouTube (不明) その他|

    @total = Hash.new()
    days.each do |day|
      @total[day] = @columns.map { |co| [co, 0] }.to_h
      @total[day]["others"] = []
    end

    @detail_logs.each do |keys, val|
      li = DetailLog.link_source("", keys[1])

      # col = case li
      # when @columns.method(:include?); li
      # when "";                         "不明"
      # else;                            "その他"
      # end

     if li.in?(@columns)
        col = li
      else
        col = "その他"
        @total[keys[0].to_date]["others"] << li
      end

      @total[keys[0].to_date][col] += val
    end

    @toppage_logs.each do |keys, val|
      li = DetailLog.link_source("", keys[1])

      # col = case li
      # when @columns.method(:include?); li
      # when "";                         "不明"
      # else;                            "その他"
      # end

      if li.in?(@columns)
         col = li
       else
         col = "その他"
         @total[keys[0].to_date]["others"] << li
       end


      @total[keys[0].to_date][col] += val
    end

  end
end
