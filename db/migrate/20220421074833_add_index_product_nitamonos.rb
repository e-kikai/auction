class AddIndexProductNitamonos < ActiveRecord::Migration[5.2]
  def change
    add_index  :product_nitamonos, [:product_id, :nitamono_id], unique: true
  end
end
