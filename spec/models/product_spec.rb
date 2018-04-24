# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  user_id               :integer          not null
#  category_id           :integer          not null
#  name                  :string           default(""), not null
#  description           :text
#  dulation_start        :datetime
#  dulation_end          :datetime
#  sell_type             :integer          default(0), not null
#  start_price           :integer
#  prompt_dicision_price :integer
#  ended_at              :datetime
#  addr_1                :string
#  addr_2                :string
#  shipping_user         :integer          default("落札者"), not null
#  shipping_type         :integer
#  shipping_comment      :string
#  delivery_date         :integer          default("未設定"), not null
#  state                 :integer          default("中古"), not null
#  state_comment         :string
#  returns               :boolean          default("返品不可"), not null
#  returns_comment       :string
#  auto_extension        :boolean          default("自動延長しない"), not null
#  early_termination     :boolean          default(FALSE), not null
#  auto_resale           :integer          default(0)
#  resaled               :integer
#  lower_price           :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  soft_destroyed_at     :datetime
#  max_price             :integer          default(0)
#  bids_count            :integer          default(0)
#  max_bid_id            :integer
#  fee                   :integer
#  code                  :string
#  template              :boolean          default(FALSE), not null
#  machinelife_id        :integer
#  machinelife_images    :text
#  shipping_no           :integer
#  cancel                :text
#  hashtags              :text             default(""), not null
#  star                  :integer
#  note                  :text
#  watches_count         :integer          default(0), not null
#  detail_logs_count     :integer          default(0), not null
#  additional            :text             default(""), not null
#  packing               :text             default(""), not null
#  youtube               :string           default(""), not null
#  international         :boolean          default("海外発送不可"), not null
#  search_keywords       :text             default(""), not null
#

require 'rails_helper'

describe Product do
  describe "#bid" do
    let(:product) { create(:product) }

    example "商品名を取得" do
      expect(product.name).to eq "商品"
    end

    example "最終入札" do
      expect(product.bids.last.amount).to eq 15000
    end
  end

  describe "for validation" do
    it { should validate_numericality_of :start_price }
  end
end
