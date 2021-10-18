class CreateAbCheckpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :ab_checkpoints do |t|
      t.string     :utag,                null: false, default: ""
      t.string     :label,               null: false
      t.string     :key,                 null: false
      t.integer    :value,  default: 0,  null: false

      t.belongs_to :user,    index: true, foreign_key: true, null: true
      t.belongs_to :product, index: true, foreign_key: true, null: true

      t.timestamps
      t.datetime   :soft_destroyed_at, index: true
    end
  end
end
