class System::DetailLogsController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    @detail_logs  = DetailLog.where(created_at: @date.beginning_of_day..@date.end_of_day).order(created_at: :desc)
    @pdetail_logs = @detail_logs.page(params[:page]).per(200)
  end
end
