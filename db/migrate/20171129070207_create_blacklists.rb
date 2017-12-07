class CreateBlacklists < ActiveRecord::Migration[5.1]
  def change
    create_table :blacklists do |t|
      t.belongs_to :user,       index: true
      t.integer    :to_user_id, index: true

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
