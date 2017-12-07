class CreateProductImages < ActiveRecord::Migration[5.1]
  def change
    create_table :product_images do |t|
      t.belongs_to :product, null: false, index: true
      t.text       :image,   null: false
      t.integer    :order_no

      t.timestamps
    end
  end
end
