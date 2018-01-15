class CreateImportlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :importlogs do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :product, index: true
      t.integer    :status
      t.string     :code
      t.text       :message

      t.timestamps
    end
  end
end
