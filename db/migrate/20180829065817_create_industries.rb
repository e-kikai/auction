class CreateIndustries < ActiveRecord::Migration[5.2]
  def change
    create_table :industries do |t|
      t.string  :name,     null: false, default: ''
      t.integer :order_no, null: false, default: 9_999_999

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
