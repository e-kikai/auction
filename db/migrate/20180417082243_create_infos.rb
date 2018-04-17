class CreateInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :infos do |t|
      t.string   :title,    null: false, default: ""
      t.text     :content,  null: false, default: ""
      t.integer  :target,   null: false, default: 0
      t.datetime :start_at, null: false, default: -> { 'NOW()' }

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
