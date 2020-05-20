class System::ToppageLogsController < System::ApplicationController
  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @toppage_logs  = ToppageLog.includes(:user)
      .where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

    @ptoppage_logs = @toppage_logs.page(params[:page]).per(500)
  end

end
