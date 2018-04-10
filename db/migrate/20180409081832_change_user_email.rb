class ChangeUserEmail < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :email
    add_index :users, [:email, :soft_destroyed_at], unique: true
  end
end
