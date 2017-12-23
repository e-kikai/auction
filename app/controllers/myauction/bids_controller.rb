class Myauction::BidsController < Myauction::ApplicationController
  def index
    @search    = current_user.bid_products.finished(params[:finished]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page]).includes(:product_images)
  end

  def new
    @product = Product.find(params[:id])
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user
  end

  def create
    @product = Product.find(params[:id])
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    if @bid.save
      if @product.max_bid.user == current_user
        mes = if @product.finished?
          "おめでとうございます。あなたが落札しました。"
        else
          "入札を行いました。現在あなたの入札が最高金額です。"
        end
        redirect_to "/myauction/bids/#{@bid.id}", notice: mes
      else
        render :new, alert: "あなたの入札より、自動入札が上回りました。"
      end
    else
      render :new
    end
  end

  def show
    @bid = Bid.find(params[:id])
  end

  private

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
