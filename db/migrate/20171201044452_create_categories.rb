class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :ancestry, index: true

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
