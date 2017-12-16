class ProductsController < ApplicationController
  def index
    @search    = Product.finished(params[:finished]).with_keywords(params[:keywords]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page])
  end

  def show
    @product = Product.find(params[:id])
    @bid     = @product.bids.new
  end

end
