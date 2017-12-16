class ProductAddColumnMaxPrice < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :max_price, :integer, default: 0, notnull: true
    add_column :products, :bids_count, :integer, default: 0, notnull: true
  end
end
