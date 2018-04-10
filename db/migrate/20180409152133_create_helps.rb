class CreateHelps < ActiveRecord::Migration[5.1]
  def change
    create_table :helps do |t|
      t.string  :title,    null: false, default: ""
      t.text    :content,  null: false, default: ""
      t.integer :target,   null: false, default: 0
      t.integer :order_no, null: false, default: 999999999

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end
end
