class AddColumnUsers01 < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :charge,  :string
    add_column :users, :fax,     :string
    add_column :users, :url,     :string
    add_column :users, :license, :string
    add_column :users, :business_hours, :string
    add_column :users, :note,    :text

    remove_column :users, :bank_account_type
    remove_column :users, :bank_account_number
    remove_column :users, :bank_account_hodler
  end
end
