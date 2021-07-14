class WatchesAddNonlogin < ActiveRecord::Migration[5.2]
  def change
    add_column    :watches,      :nonlogin, :boolean, default: false
    add_column    :detail_logs,  :nonlogin, :boolean, default: true
    add_column    :search_logs,  :nonlogin, :boolean, default: true
    add_column    :toppage_logs, :nonlogin, :boolean, default: true
    change_column :watches,      :user_id,  :integer, null: true
  end
end
