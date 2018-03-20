class RenameWatchesColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :wathes_count, :watches_count
  end
end
