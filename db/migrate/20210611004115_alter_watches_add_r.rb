class AlterWatchesAddR < ActiveRecord::Migration[5.2]
  def change
    add_column :watches,      :r,       :string
    add_column :watches,      :referer, :string
    add_column :watches,      :ip,      :string
    add_column :watches,      :host,    :string
    add_column :watches,      :ua,      :string

    add_column :watches,      :utag,    :string
    add_column :detail_logs,  :utag,    :string
    add_column :search_logs,  :utag,    :string
    add_column :toppage_logs, :utag,    :string
  end
end
