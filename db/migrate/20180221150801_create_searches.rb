class CreateSearches < ActiveRecord::Migration[5.1]
  def change
    create_table :searches do |t|
      t.belongs_to :user, index: true
      t.belongs_to :category
      t.belongs_to :product_image
      t.string     :name
      t.text       :keywords
      t.text       :s
      t.boolean    :publish

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end

    add_column :products, :hashtags, :text
  end
end
