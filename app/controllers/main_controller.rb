class MainController < ApplicationController
  def index
    @root_categories = Category.root_categories

    # 最近チェックした商品

    # チェックした商品の関連商品
  end
end
