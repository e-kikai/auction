class System::WatchesController  < System::ApplicationController
  def index
    @watches = Watch.unscoped.all.includes(:user, product: [:max_bid]).order(created_at: :desc)
    @pwatches = @watches.page(params[:page]).per(500)
  end
end
