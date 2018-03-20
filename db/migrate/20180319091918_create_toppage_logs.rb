class CreateToppageLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :toppage_logs do |t|
      t.belongs_to :user, index: true

      t.string      :ip
      t.string      :host
      t.string      :referer
      t.string      :ua

      t.timestamps
    end
  end
end
