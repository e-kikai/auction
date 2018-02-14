class Myauction::BidsController < Myauction::ApplicationController
  def index
    @search    = current_user.bid_products.search(params[:q])
    @products  = @search.result

    @products = if params[:cond] == '2'
      @products.status(2).where(" products.max_bid_id = bids.id ").order(dulation_end: :desc)
    else
      @products.status(0).order(:dulation_end)
    end

    @pproducts = @products.page(params[:page]).preload(:product_images, :user, max_bid: :user)
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
        @bid.amount = nil # 一度金額をクリア
        flash.now[:alert] = "あなたの入札より、自動入札が上回りました。"
        render :new
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
