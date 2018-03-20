class AddWathesCountToProducts < ActiveRecord::Migration[5.1]
  def self.up
    add_column :products, :wathes_count, :integer, null: false, default: 0
    add_column :products, :detail_logs_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :products, :wathes_count
    remove_column :products, :detail_logs_count
  end
end
