class System::TradesController < System::ApplicationController
  include Exports

  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    # @trades = Trade.includes(:product, :user).where(created_at: @date.to_time.all_month, product_id: params[:id]).order(created_at: :desc)
    @trades = Trade.includes(:product, :user).order(created_at: :desc)
    respond_to do |format|
      format.html {
        @ptrades = @trades.page(params[:page]).per(500)
      }
      format.csv { export_csv "trades_#{@date.strftime('%Y_%m')}.csv" }
    end


  end
end
