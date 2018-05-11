class System::SearchLogsController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now

    @search_logs  = SearchLog.includes(:user, :category, :company).where(created_at: @date.beginning_of_day..@date.end_of_day).order(created_at: :desc)
    @psearch_logs = @search_logs.page(params[:page]).per(500)
  end
end
