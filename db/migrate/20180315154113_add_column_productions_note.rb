class AddColumnProductionsNote < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :note,    :text
    
    remove_column :products, :shipping_cost
    remove_column :products, :shipping_okinawa
    remove_column :products, :shipping_hokkaido
    remove_column :products, :shipping_island

    remove_column :users, :bank_branch

  end
end
