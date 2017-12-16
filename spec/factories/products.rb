# == Schema Information
#
# Table name: products
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  category_id            :integer          not null
#  name                   :string           default(""), not null
#  description            :text
#  dulation_start         :datetime
#  dulation_end           :datetime
#  sell_type              :integer          default(0), not null
#  start_price            :integer
#  prompt_dicision_price  :integer
#  ended_at               :datetime
#  addr_1                 :string
#  addr_2                 :string
#  shipping_user          :integer          default("落札者"), not null
#  shipping_type          :integer
#  delivery               :string
#  shipping_cost          :integer
#  shipping_okinawa       :integer
#  shipping_hokkaido      :integer
#  shipping_island        :integer
#  international_shipping :string
#  delivery_date          :integer          default("1〜2で発送"), not null
#  state                  :integer          default("中古"), not null
#  state_comment          :string
#  returns                :boolean          default(FALSE), not null
#  returns_comment        :string
#  auto_extension         :boolean          default(FALSE), not null
#  early_termination      :boolean          default(FALSE), not null
#  auto_resale            :integer
#  resaled                :integer
#  lower_price            :integer
#  special_featured       :boolean          default(FALSE), not null
#  special_bold           :boolean          default(FALSE), not null
#  special_bgcolor        :boolean          default(FALSE), not null
#  special_icon           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  soft_destroyed_at      :datetime
#

FactoryBot.define do
  factory :product do
    user
    category

    name                  "商品"
    start_price           10000
    prompt_dicision_price 30000

    after(:build) do |product|
      user_01 = build(:user, name: "ユーザA")
      user_02 = build(:user, name: "ユーザB")
      product.bids << build(:bid, user_id: user_01.id, amount: 12000)
      product.bids << build(:bid, user_id: user_02.id, amount: 15000)
    end
  end
end
