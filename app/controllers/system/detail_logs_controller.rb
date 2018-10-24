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
end
