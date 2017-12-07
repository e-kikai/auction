# == Schema Information
#
# Table name: products
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  category_id            :integer
#  name                   :string
#  description            :text
#  dulation_start         :datetime
#  dulation_end           :datetime
#  type                   :integer
#  start_price            :integer
#  prompt_dicision_price  :integer
#  ended_at               :datetime
#  addr_1                 :string
#  addr_2                 :string
#  shipping_user          :integer
#  shipping_type          :integer
#  delivery               :string
#  shipping_cost          :integer
#  shipping_okinawa       :integer
#  shipping_hokkaido      :integer
#  shipping_island        :integer
#  international_shipping :string
#  delivery_date          :integer
#  state                  :integer
#  state_comment          :string
#  returns                :boolean
#  returns_comment        :string
#  auto_extension         :boolean
#  early_termination      :boolean
#  auto_resale            :integer
#  resaled                :integer
#  lower_price            :integer
#  special_featured       :boolean
#  special_bold           :boolean
#  special_bgcolor        :boolean
#  special_icon           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  soft_destroyed_at      :datetime
#

require 'rails_helper'

describe Product do
  describe "#bid" do
    # let(:product) { Product.new(name: "テスト", start_price: 10000, bids: bids) }
    # let(:bids) {[
    #
    # ]}

    let(:product) { create(:product) }

    example "商品名を取得" do
      expect(product.name).to eq "商品"
    end
  end
end
