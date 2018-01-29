class Myauction::CategoriesController < ApplicationController
  include Exports

  def index
    @categories  = Category.all.order(:id)

    respond_to do |format|
      format.html
      format.csv { export_csv "categories.csv" }
    end
  end
end
