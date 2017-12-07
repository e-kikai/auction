class ProductsController < ApplicationController
  def index
    @search    = @products.with_keywords(params[:keywords]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page])
  end

  def show
    @product = @products.find(params[:id])
  end

end
