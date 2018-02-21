class AddColumnProductionCancel < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :cancel, :text

    change_column :users, :bank, :text
  end
end
