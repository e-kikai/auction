class System::SearchLogsController < System::ApplicationController
  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @search_logs  = SearchLog.includes(:user, :category, :company, :search)
      .where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @psearch_logs = @search_logs.page(params[:page]).per(500)
      }
      format.csv { export_csv "search_logs_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
