class Myauction::TradesController < Myauction::ApplicationController
  def index
    @product        = Product.find(params[:product_id])
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: @product.max_bid.user.addr_1)

    @trades = @product.trades.order(id: :desc)
    @trade  = @product.trades.new
  end

  def create
    @product = Product.find(params[:product_id])

    if @product.user_id != current_user.id && @product.max_bid.user_id != current_user.id
      flash.now[:alert] = "この商品に投稿できませんでした"
      render :index
    end

    @trade = @product.trades.new(trade_params.merge(user_id: current_user.id))
    if @trade.save
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

  def trade_params
    params.require(:trade).permit(:comment)
  end
end
