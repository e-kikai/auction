class ProductsAddColumnMaxBidId < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :max_bid_id, :integer
    add_column :products, :resale_count, :integer, default: 0, notnull: false
  end
end
