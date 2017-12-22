class Myauction::BidsController < Myauction::ApplicationController
  def index
    @search    = current_user.bid_products.finished(params[:finished]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page])
  end

  def new
    @product = Product.find(params[:id])
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    render :show unless @bid.valid?
  end

  def create
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    if @bid.save
      redirect_to "/myauction/#{@product.id}/result", notice: "#{@product.name}に入札を行いました"
    else
      render :show
    end
  end

  def show
  end

  private

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
