class System::AlertsController < System::ApplicationController
  def index
    @alerts = Alert.unscoped.all.includes(:user, :category, :company).order(created_at: :desc)
    @palerts = @alerts.page(params[:page]).per(500)
  end
end
