class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:conf, :bid, :result]
  before_action :get_product,        only: [:show, :conf, :bid, :result]

  def index
    @search    = Product.finished(params[:finished]).with_keywords(params[:keywords]).search(params[:q])

    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @search = @search.result.search(category_id_in: @category.subtree_ids)
    end

    @products  = @search.result
    @pproducts = @products.page(params[:page]).includes(:product_images)
  end

  def show
    @bid = @product.bids.new
  end

  private

  def get_product
    @product = Product.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end

end
