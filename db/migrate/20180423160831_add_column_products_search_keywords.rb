class AddColumnProductsSearchKeywords < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :search_keywords, :text, null: false, default: ""

    add_column :helps, :uid, :string, null: false, default: ""
    add_column :infos, :uid, :string, null: false, default: ""
  end
end
