class SearchlogsAddPathPage < ActiveRecord::Migration[5.2]
  def change
    add_column :search_logs, :path, :string,  null: false, default: ""
    add_column :search_logs, :page, :integer, null: false, default: 1
  end
end
