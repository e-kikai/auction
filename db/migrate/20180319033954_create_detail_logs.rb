class CreateDetailLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :detail_logs do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :product, index: true

      t.string :ip
      t.string :host
      t.string :ua

      t.timestamps
    end
  end
end
