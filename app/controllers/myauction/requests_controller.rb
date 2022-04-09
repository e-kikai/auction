class Myauction::RequestsController < Myauction::ApplicationController
  include MonthSelector
  include Exports

  # before_action :check_seller, only: [:index]
  before_action :month_selector, only: [:index]

  def index
    @requests  = current_user.requests.where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html { @prequests = @requests.page(params[:page]).per(100) }
      format.csv  { export_csv "requests_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

  def new
    @request = current_user.requests.new
  end

  def create
    @request = current_user.requests.new(request_params)

    if @request.save
      redirect_to "/myauction/requests/fin", notice: "出品リクエストを送信しました。"
    else
      redirect_to "/myauction/requests/new", alert: "出品リクエスト送信に失敗しました。"
    end
  end

  def end
  end

  private

  def request_params
    params.require(:request).permit(:name, :detail).merge(
      ip:   ip,
      host: (Resolv.getname(ip) rescue ""),
      ua:   request.user_agent,
      utag: session[:utag],
    )
  end
end
