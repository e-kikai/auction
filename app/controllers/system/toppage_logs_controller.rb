class System::ToppageLogsController < System::ApplicationController
  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @toppage_logs  = ToppageLog.includes(:user)
      .where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @ptoppage_logs = @detail_logs.page(params[:page]).per(500)
      }
      format.csv { export_csv "toppage_logs_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

end
