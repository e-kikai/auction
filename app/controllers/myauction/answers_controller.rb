class Myauction::AnswersController < Myauction::ApplicationController
  before_action :check_seller
  before_action :check_product, only: [ :show, :create ]
  before_action :check_owner,   only: [ :show, :create ]

  ### ユーザからの問合せ一覧 ###
  def index
    @threads = Trade.group(:product_id, :owner_id).where(product_id: Product.where(user_id: current_user.id))

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

  ### 問合せ回答 ###
  def show
    if @product.max_bid.present?
      @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: @product.max_bid.user.addr_1)
    end

    @trades = Trade.where(product_id: params[:product_id], owner_id: [nil, params[:owner_id]]).order(id: :desc)

    @trade  = @product.trades.new
  end

  def create
    @trade = @product.trades.new(trade_params.merge(owner_id: @owner.id, user_id: current_user.id))

    if @trade.save
      # if @product.user_id == current_user.id
      #   BidMailer.trade_user(@trade).deliver
      # else
      #   BidMailer.trade_company(@trade).deliver
      # end

      if @product.trade_success?(@owner)
        BidMailer.answer_success(@trade, @product, @owner).deliver
      else
        BidMailer.answer(@trade, @product, @owner).deliver
      end

      redirect_to "/myauction/answers/#{params[:product_id]}/#{params[:owner_id]}", notice: "ユーザからの問合せ・取引について回答の投稿を行いました"
    else
      flash.now[:alert] = "ユーザからの問合せ・取引について回答の投稿に失敗しました"
      render :show
    end
  end

  private

  def check_owner
    redirect_to "/myauction/answers/", alert: "回答するユーザが指定されていません" if params[:owner_id].blank?

    @owner = User.find(params[:owner_id])
  rescue
    redirect_to "/myauction/answers/", alert: "#{params[:owner_id]} : 指定した回答するユーザが存在しません"
  end

  def check_product
    redirect_to "/myauction/answers/", alert: "商品が指定されていません" if params[:product_id].blank?

    @product = current_user.products.find(params[:product_id])
  rescue
    redirect_to "/myauction/answers/", alert: "#{params[:product_id]} : 指定した商品は、貴社の商品でないか、存在しません"
  end

  def trade_params
    params.require(:trade).permit(:comment)
  end
end
