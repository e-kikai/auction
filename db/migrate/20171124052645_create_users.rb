class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string  :account, unique: true

      t.string  :name
      t.string  :zip
      t.string  :birthday
      t.boolean :allow_mail

      t.boolean :seller

      t.string  :company
      t.string  :contact_name

      t.string  :addr_1
      t.string  :addr_2
      t.string  :addr_3
      t.string  :tel

      t.string  :bank
      t.string  :bank_branch
      t.integer :bank_account_type
      t.string  :bank_account_number
      t.string  :bank_account_hodler

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
