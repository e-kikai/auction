class ChangeColumnProductsAutoResale < ActiveRecord::Migration[5.1]
  def change
    change_column_default :products, :auto_resale, 0

    rename_column         :products, :resale_count, :fee
    change_column_default :products, :fee, nil
  end
end
