class Myauction::TradesController < Myauction::ApplicationController
  before_action :check_product, only: [ :index, :create, :destroy ]

  def index
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: @product.max_bid.user.addr_1)

    @trades = @product.trades.order(id: :desc)
    @trade  = @product.trades.new
  end

  def create
    @trade = @product.trades.new(trade_params.merge(user_id: current_user.id))
    if @trade.save
      if @product.user_id == current_user.id
        BidMailer.trade_user(@trade).deliver
      else
        BidMailer.trade_company(@trade).deliver
      end

      redirect_to "/myauction/trades?product_id=#{params[:product_id]}", notice: "取引投稿を行いました"
    else
      flash.now[:alert] = "取引投稿に失敗しました"
      render :index
    end
  end

  def destroy
    @trade = current_user.trades.find(params[:id])
    @trade.soft_destroy!

    redirect_to "/myauction/products/", notice: "取引投稿をを削除しました"
  end

  private

  def check_product
    @product = Product.status(Product::STATUS[:success]).find(params[:product_id])

    ### 新ページリダイレクト ###
    if @product.user_id == current_user.id
      redirect_to "/myauction/answers/#{@product.id}/#{@product.max_bid.user_id}"
    else
      redirect_to "/myauction/contacts/#{@product.id}"
    end
    
    if @product.user_id != current_user.id && @product.max_bid.user_id != current_user.id
      redirect_to "/myauction/bids?cond=2", notice: "#{@product.name}はあなたが落札した商品ではありません"
    end
  end

  def trade_params
    params.require(:trade).permit(:comment)
  end
end
