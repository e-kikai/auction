class SearchRename < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :s, :q
  end
end
