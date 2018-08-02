class Myauction::AlertsController < Myauction::ApplicationController
  before_action :get_alert, only: [:edit, :update, :destroy]

  def index
    @alerts  = current_user.alerts
    @palerts = @alerts.page(params[:page])
  end

  def new
    @alert = current_user.alerts.new(alert_params)
  end

  def create
    @alert = current_user.alerts.new(alert_params)
    if @alert.save
      redirect_to "/myauction/alerts", notice: "通知条件「#{@alert.name}」を登録しました"
    else
      redirect_to "/myauction/alerts", alert: "通知条件「#{@alert.name}」を登録できませんでした"
    end
  end

  def edit
  end

  def update
    if @alert.update(alert_params)
      redirect_to "/myauction/alerts/", notice: "通知条件「#{@alert.name}」を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @alert.soft_destroy!
    redirect_to "/myauction/alerts/", notice: "通知条件「#{@alert.name}」を削除しました"
  end

  private

  def get_alert
    @alert = current_user.alerts.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:name, :keywords, :category_id, :company_id)
  end
end
