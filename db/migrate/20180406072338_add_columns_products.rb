class AddColumnsProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :additional, :text,   null: false, default: ""
    add_column :products, :packing,    :text,   null: false, default: ""
    add_column :products, :youtube,    :string, null: false, default: ""

    add_column :products, :international, :boolean, null: false, default: false

    rename_column :products, :delivery, :shipping_comment

    add_column :users, :result_message, :text,   null: false, default: ""
    add_column :users, :header_image,   :text
    add_column :users, :machinelife_id, :integer

    remove_column :products, :special_featured
    remove_column :products, :special_bold
    remove_column :products, :special_bgcolor
    remove_column :products, :special_icon
    remove_column :products, :international_shipping
  end
end
