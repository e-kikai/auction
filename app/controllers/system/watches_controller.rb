class System::WatchesController  < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector

  def index
    @watches = Watch.unscoped.includes(:user, product: [:user, :category, max_bid: [:user]])
      .where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @pwatches = @watches.page(params[:page]).per(100)
      }
      format.csv { export_csv "watch_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

end
