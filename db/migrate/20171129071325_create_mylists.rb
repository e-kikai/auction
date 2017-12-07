class CreateMylists < ActiveRecord::Migration[5.1]
  def change
    create_table :mylists do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :product, index: true

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
