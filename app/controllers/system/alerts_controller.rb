class System::AlertsController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector

  def index
    @alerts = Alert.unscoped.includes(:user, :category, :company)
      .where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @palerts = @alerts.page(params[:page]).per(100)
      }
      format.csv { export_csv "alert_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
