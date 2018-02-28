class AddColumnProductsStar < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :start, :integer
  end
end
