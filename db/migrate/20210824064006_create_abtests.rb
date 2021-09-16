class CreateAbtests < ActiveRecord::Migration[5.2]
  def change
    create_table :abtests do |t|
      t.belongs_to :user,     index: true, foreign_key: true, null: true
      t.string     :utag,                                     null: false, default: ""
      t.string     :label,                                    null: false
      t.integer    :segment,                                  null: false
      t.integer    :status, default: 0,                       null: false

      t.timestamps
      t.datetime   :soft_destroyed_at, index: true
    end
  end
end
