class ProductsAddAutoResaleDate < ActiveRecord::Migration[5.2]
  def change
    add_column            :products, :auto_resale_date, :integer, null: false, default: 7
    change_column_default :products, :auto_resale, 8
  end
end
