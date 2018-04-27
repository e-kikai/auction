class AddColumnCategoriesPathOrderNo < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :search_order_no, :string, null: false, default: ""

    add_index :helps, :uid, unique: true
    add_index :infos, :uid, unique: true
  end
end
