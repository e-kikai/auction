class MainController < ApplicationController
  def index
    @roots = Category.roots.order(:order_no)

    # 最近チェックした商品

    # チェックした商品の関連商品

    # 新着
    @new_products = Product.status(Product::STATUS[:start]).order(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)
  end
end
