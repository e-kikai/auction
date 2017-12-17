class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:conf, :bid, :result]
  before_action :get_product,        only: [:show, :conf, :bid, :result]
  def index
    @search    = Product.finished(params[:finished]).with_keywords(params[:keywords]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page])
  end

  def show
    @bid = @product.bids.new
  end

  def conf
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    render :show unless @bid.valid?
  end

  def bid
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    if @bid.save
      redirect_to "/products/#{@product.id}/result", notice: "#{@product.name}に入札を行いました"
    else
      render :show
    end
  end

  def result
  end

  private

  def get_product
    @product = Product.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end

end
