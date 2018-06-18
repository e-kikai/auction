class CreateResultLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :result_logs do |t|
      t.belongs_to :product, index: true
      t.belongs_to :bid_id
      t.datetime   :result_at, index: true

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end

  add_column :detail_logs, :r, :string, null: false, default: ""
end
