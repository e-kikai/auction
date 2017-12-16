class ChangeUsersDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_null :products, :user_id, false
    change_column :products, :name,          :string,  default: "", null: false

    change_column :products, :type,          :integer, default: 0, null: false
    change_column :products, :shipping_user, :integer, default: 0, null: false
    change_column :products, :delivery_date, :integer, default: 0, null: false
    change_column :products, :state,         :integer, default: 0, null: false

    change_column :products, :returns,           :boolean, default: false, null: false
    change_column :products, :auto_extension,    :boolean, default: false, null: false
    change_column :products, :early_termination, :boolean, default: false, null: false
    change_column :products, :special_featured,  :boolean, default: false, null: false
    change_column :products, :special_bold,      :boolean, default: false, null: false
    change_column :products, :special_bgcolor,   :boolean, default: false, null: false

    change_column :users, :allow_mail, :boolean, default: false, null: false
    change_column :users, :seller,     :boolean, default: false, null: false
    change_column :users, :account,    :string,  unique: true

    change_column :bids, :amount, :integer, default: 0, null: false
    change_column_null :bids, :product_id, false
    change_column_null :bids, :user_id,    false

    change_column_null :follows, :user_id,    false
    change_column_null :follows, :to_user_id, false

    change_column_null :blacklists, :user_id,    false
    change_column_null :blacklists, :to_user_id, false

    change_column_null :mylists, :user_id,    false
    change_column_null :mylists, :product_id, false
    rename_table :mylists, :watches

    change_column_null :product_images, :product_id, false

    add_column :categories, :order_no, :integer, default: 999999999, null: false

  end
end
