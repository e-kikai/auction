class ChangeProductsType < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :type, :sell_type

    change_column_null :products, :category_id, false
  end
end
