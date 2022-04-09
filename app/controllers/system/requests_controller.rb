class System::RequestsController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector, only: [:index]

  def index
    @requests  = Request.includes(:user).where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html { @prequests = @requests.page(params[:page]).per(100) }
      format.csv  { export_csv "requests_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
