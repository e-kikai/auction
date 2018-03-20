class MainController < ApplicationController
  def index
    @roots = Category.roots.order(:order_no)

    # 最近チェックした商品

    # チェックした商品の関連商品

    # フォローした出品会社の新着
    if user_signed_in?
      if follows_user_ids = current_user.follows.pluck(:user_id)
        @follows_new_products = Product.status(Product::STATUS[:start]).includes(:product_images).where(user_id: follows_user_ids).order(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)
      end
    end


    # 新着
    @new_products = Product.status(Product::STATUS[:start]).includes(:product_images).order(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)

    # トップページ公開検索条件
    @searches = Search.where(publish: true).order("RANDOM()").limit(9)
  end
end
