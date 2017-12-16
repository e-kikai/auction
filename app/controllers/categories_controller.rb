class CategoriesController < ApplicationController
  def index
    @root_categories = Category.root_categories

  end

  def show
    @category = Category.find(params[:id])

    # 個別ページがあれば、それを表示

    # なければ、検索結果にリダイレクト
    redirect_to controller: :products, action: :index, params: { q: { category_id_eq: @category.id }}
  end
end
