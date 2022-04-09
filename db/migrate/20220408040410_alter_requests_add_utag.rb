class AlterRequestsAddUtag < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :ip,      :string
    add_column :requests, :host,    :string
    add_column :requests, :utag,    :string
    add_column :requests, :ua,      :string

    add_column :requests, :display, :boolean, default: false
  end
end
