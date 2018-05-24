class System::BidsController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i) : Time.now
    @company = params[:company]

    @bids  = Bid.includes(:product, :user).where(created_at: @date.all_day).order(created_at: :desc)

    if @company.present?
      product_ids = User.find(@company).products.select(:id)
      @bids = @bids.where(product_id: product_ids)
    end

    @pbids = @bids.page(params[:page]).per(500)

    @company_selectors = User.companies.order(:id).map { |co| [co.company_remove_kabu, co.id] }
  end
end
