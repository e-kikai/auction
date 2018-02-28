class RenameColumnProductsStartStar < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :start, :star
  end
end
