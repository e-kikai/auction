class ChangeColumnProductsHashtags < ActiveRecord::Migration[5.1]
  def change
    change_column :products, :hashtags, :text, null: false, default: ""
  end
end
