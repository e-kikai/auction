class System::BidsController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now

    @bids  = Bid.includes(:product, :user).where(created_at: @date.beginning_of_day..@date.end_of_day).order(created_at: :desc)
    @pbids = @bids.page(params[:page]).per(500)
  end
end
