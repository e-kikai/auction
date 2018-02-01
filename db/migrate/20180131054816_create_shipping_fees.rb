class CreateShippingFees < ActiveRecord::Migration[5.1]
  def change
    create_table :shipping_fees do |t|
      t.belongs_to :user, index: true
      t.integer    :shipping_no
      t.string     :addr_1
      t.integer    :price
      t.timestamps
    end

    add_column :products, :shipping_no, :integer
  end
end
