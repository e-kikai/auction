class CreateProductNitamonos < ActiveRecord::Migration[5.2]
  def change
    create_table :product_nitamonos do |t|
      t.belongs_to :product,     index: true, foreign_key: true, null: false
      t.integer    :nitamono_id, index: true, foreign_key: true, null: false
      t.float      :norm,                                        null: false

      t.timestamps
      t.datetime   :soft_destroyed_at, index: true
    end
  end
end
