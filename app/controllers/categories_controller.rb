class CategoriesController < ApplicationController
  def index
    @root_categories = Category.root_categories

  end
end
