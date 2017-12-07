class MainController < ApplicationController
  def index
    @categories = Category.all

    # 最近チェックした商品

    # チェックした商品の関連商品
  end
end
