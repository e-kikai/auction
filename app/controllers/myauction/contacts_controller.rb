class Myauction::ContactsController < Myauction::ApplicationController
  before_action :check_product, only: [ :show, :create ]
  before_action :check_owner,   only: [ :show, :create ]

  ### 商品問合せ一覧 ###
  def index
    @threads = Trade.group(:product_id, :owner_id).where(owner_id: current_user.id)

    # @thread_lasts  = @threads.maximum(:created_at)
    @pthread_lasts = @threads.order("maximum_created_at DESC").page(params[:page]).per(50).maximum(:created_at)

    product_ids = @pthread_lasts.map { |k, v| k[0] }
    owner_ids   = @pthread_lasts.map { |k, v| k[1] }

    @where_trades   = Trade.where(product_id: product_ids, owner_id: owner_ids).group(:product_id, :owner_id)
    @thread_starts  = @where_trades.minimum(:created_at)
    @thread_counts  = @where_trades.count

    @products = Product.includes(:user).where(id: product_ids).index_by(&:id)
    @owners   = User.where(id: owner_ids).index_by(&:id)

    count = Trade.from(@threads.distinct.select(:product_id, :owner_id)).count

    @paginatable_array = Kaminari.paginate_array([], total_count: count).page(params[:page]).per(50)
  end

  def show
    # @trades = Trade.where(product_id: params[:product_id], owner_id: params[:owner_id]).order(id: :desc)
    @trades = Trade.where(product_id: params[:id], owner_id: [nil, @owner.id]).order(id: :desc)

    @trade  = @product.trades.new
  end

  def create
    @trade = @product.trades.new(trade_params.merge(owner_id: @owner.id, user_id: @owner.id))

    if @trade.save
      if @product.trade_success?(@owner)
        BidMailer.contact_success(@trade, @product, @owner).deliver
      else
        BidMailer.contact(@trade, @product, @owner).deliver
      end

      redirect_to "/myauction/contacts/#{params[:id]}", notice: "問合せ・取引の投稿を行いました"
    else
      flash.now[:alert] = "問合せ・取引の投稿に失敗しました"
      render :show
    end
  end

  private

  def check_owner
    @owner = current_user
  end

  def check_product
    redirect_to "/myauction/contacts/", alert: "商品が指定されていません" if params[:id].blank?

    @product = Product.find(params[:id])
  rescue
    redirect_to "/myauction/contacts/", alert: "#{params[:id]} : 指定した商品情報を取得できませんでした"
  end

  def trade_params
    params.require(:trade).permit(:comment)
  end
end
