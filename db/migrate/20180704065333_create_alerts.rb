class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.belongs_to :user, index: true
      t.belongs_to :category
      t.belongs_to :product_image
      t.text       :keywords

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

      t.timestamps
    end

    add_column :products, :stock, :integer
    add_column :products, :dst_id, :integer
  end
end
