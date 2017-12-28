class ProductsAddColumnTemplateBoolean < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :template, :boolean, default: false, null: false
  end
end
