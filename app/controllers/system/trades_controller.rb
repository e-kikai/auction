class System::TradesController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector, only: :index

  def index
    #####
    @threads_02 = Trade.includes(@includes_product, :owner)
      .where(id: Trade.group(:product_id, :owner_id).select('max(id)'))
      .where(created_at: @rrange)
      .order(created_at: :desc)

    @threads_02 = @threads_02.where(product_id: Product.where(user_id: params[:company])) if params[:company].present?

    @th_group = Trade.group(:product_id, :owner_id)
      .where(product_id: @threads_02.select(:product_id), owner_id: @threads_02.select(:owner_id))

    @thread_starts_02  = @th_group.minimum(:created_at)
    @thread_counts_02  = @th_group.count

    ####
    # @threads       = Trade.group(:product_id, :owner_id)
    # @threads       = @threads.where(product_id: Product.where(user_id: @company)) if @company.present?
    # @thread_lasts  = @threads.maximum(:created_at)
    # @pthread_lasts = @threads.order("maximum_created_at DESC").page(params[:page]).per(50).maximum(:created_at)

    # product_ids = @pthread_lasts.map { |k, v| k[0] }
    # owner_ids   = @pthread_lasts.map { |k, v| k[1] }

    # @where_trades   = Trade.where(product_id: product_ids, owner_id: owner_ids).group(:product_id, :owner_id)
    # @thread_starts  = @where_trades.minimum(:created_at)
    # @thread_counts  = @where_trades.count

    # @products = Product.includes(:user).where(id: product_ids).index_by(&:id)
    # @owners   = User.where(id: owner_ids).index_by(&:id)

    # count = Trade.from(@threads.distinct.select(:product_id, :owner_id)).count

    # @paginatable_array = Kaminari.paginate_array([], total_count: count).page(params[:page]).per(50)

    respond_to do |format|
      format.html {
        @pthreads = @threads_02.page(params[:page]).per(50)
      }
      format.csv {
        export_csv "trades_#{@date.strftime('%Y_%m')}.csv"
      }
    end
  end

  def show
    @owner   = User.find(params[:owner_id])
    @product = Product.includes(:user).find(params[:product_id])

    if @product.max_bid.present?
      @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: @product.max_bid.user.addr_1)
    end

    # @trades = Trade.where(product_id: params[:product_id], owner_id: params[:owner_id]).order(id: :desc)
    @trades = Trade.where(product_id: params[:product_id], owner_id: [nil, params[:owner_id]]).order(id: :desc)
  end

  # def remake_owner
  #   trades = Trade.where(owner_id: nil)
  #
  #   trades.each { |t| t.owner_id = t.product.max_bid.user_id; t.save }
  #
  #   render plain: 'OK', status: 200
  # end
end
