class CreateShippingLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :shipping_labels do |t|
      t.belongs_to :user, index: true
      t.integer    :shipping_no
      t.string     :name,

      t.timestamps
    end
  end
end
