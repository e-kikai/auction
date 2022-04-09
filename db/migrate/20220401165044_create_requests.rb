class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.belongs_to :user,   index: true, foreign_key: true, null: false
      t.string     :name,                                   null: false
      t.text       :detail, default: ""
      t.timestamps
      t.datetime   :soft_destroyed_at, index: true
    end
  end
end
