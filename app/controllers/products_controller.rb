class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:conf, :bid, :result]
  before_action :get_product,        only: [:show, :conf, :bids]

  def index
    cond = params[:success].present? ? Product::STATUS[:success] : Product::STATUS[:start] # 終了した商品
    @search = Product.status(cond).with_keywords(params[:keywords]).search(params[:q])

    # カテゴリ
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @search   = @search.result.search(category_id_in: @category.subtree_ids)
    end

    # 出品会社
    if params[:company_id].present?
      @company = User.companies.find(params[:company_id])
      @search  = @search.result.search(user_id_eq: params[:company_id])
    end

    @products  = @search.result.includes(:product_images, :category, :user)
    @pproducts = @products.page(params[:page])

    # フィルタリング
    @select_categories = @products.joins(:category).group(:category_id).group("categories.name").reorder("count_id DESC").count
    @select_addr1      = @products.group(:addr_1).reorder(:addr_1).count

    @roots = Category.roots.order(:order_no)
  end

  def show
    @bid = @product.bids.new
    @shipping_label = ShippingLabel.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no)
    if user_signed_in?
      @shipping_fee   = ShippingFee.find_by(user_id: @product.user_id, shipping_no: @product.shipping_no, addr_1: current_user.addr_1)
    end
  end

  def bids
  end

  private

  def get_product
    @product = Product.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end

end
