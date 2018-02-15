class MainController < ApplicationController
  def index
    @roots = Category.roots.order(:order_no)

    # 最近チェックした商品

    # チェックした商品の関連商品
  end
end
