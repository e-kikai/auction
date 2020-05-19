class AlterUserSpecial < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :special, :boolean, nill: false, default: false

    add_column :toppage_logs, :r, :string, null: false, default: ""
    add_column :search_logs,  :r, :string, null: false, default: ""

    add_column :products, :maker,     :string,  null: false, default: ""
    add_column :products, :model,     :string,  null: false, default: ""
    add_column :products, :year,      :string,  null: false, default: ""
    add_column :products, :commision, :boolean, nill: false, default: false
    add_column :products, :accesory , :string,  nill: false, default: ""
    add_column :products, :suspend,   :datetime
  end
end
