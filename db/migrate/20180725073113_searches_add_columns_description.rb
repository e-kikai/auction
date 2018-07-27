class SearchesAddColumnsDescription < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :description, :text, nill: false, default: ""
  end
end
