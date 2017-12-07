class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.belongs_to :user,     index: true
      t.belongs_to :category, index: true

      t.string     :name
      t.text       :description

      t.datetime   :dulation_start
      t.datetime   :dulation_end

      t.integer    :type
      t.integer    :start_price
      t.integer    :prompt_dicision_price

      t.datetime   :ended_at

      t.string     :addr_1
      t.string     :addr_2

      t.integer    :shipping_user
      t.integer    :shipping_type

      t.string     :delivery
      t.integer    :shipping_cost
      t.integer    :shipping_okinawa
      t.integer    :shipping_hokkaido
      t.integer    :shipping_island

      t.string     :international_shipping

      t.integer    :delivery_date

      t.integer    :state
      t.string     :state_comment
      t.boolean    :returns
      t.string     :returns_comment

      ### オプション類 ###
      t.boolean    :auto_extension
      t.boolean    :early_termination
      t.integer    :auto_resale
      t.integer    :resaled
      t.integer    :lower_price

      t.boolean    :special_featured
      t.boolean    :special_bold
      t.boolean    :special_bgcolor
      t.integer    :special_icon

      # t.integer    :seller_star
      # t.text       :seller_star_comment
      # t.integer    :buyer_star
      # t.text       :buyer_star_comment

      t.timestamps
      t.datetime :soft_destroyed_at, index: true
    end
  end
end
