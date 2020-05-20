class System::SearchLogsController < System::ApplicationController
  def index
    # @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    # @search_logs  = SearchLog.includes(:user, :category, :company).where(created_at: @date.beginning_of_day..@date.end_of_day).order(created_at: :desc)

    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @search_logs  = SearchLog.includes(:user, :category, :company, :search)
      .where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

    @psearch_logs = @search_logs.page(params[:page]).per(500)

    respond_to do |format|
      format.html {
        @pdetail_logs = @detail_logs.page(params[:page]).per(500)
      }
      format.csv { export_csv "search_logs_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
