# == Schema Information
#
# Table name: products
#
#  id                    :bigint           not null, primary key
#  accesory              :string           default("")
#  additional            :text             default(""), not null
#  addr_1                :string
#  addr_2                :string
#  auto_extension        :boolean          default("自動延長する"), not null
#  auto_resale           :integer          default(8)
#  auto_resale_date      :integer          default(7), not null
#  bids_count            :integer          default(0)
#  cancel                :text
#  code                  :string
#  commision             :boolean          default(FALSE)
#  delivery_date         :integer          default("未設定"), not null
#  description           :text
#  detail_logs_count     :integer          default(0), not null
#  dulation_end          :datetime
#  dulation_start        :datetime
#  early_termination     :boolean          default(FALSE), not null
#  ended_at              :datetime
#  fee                   :integer
#  hashtags              :text             default(""), not null
#  international         :boolean          default("海外発送不可"), not null
#  lower_price           :integer
#  machinelife_images    :text
#  maker                 :string           default(""), not null
#  max_price             :integer          default(0)
#  model                 :string           default(""), not null
#  name                  :string           default(""), not null
#  note                  :text
#  packing               :text             default(""), not null
#  prompt_dicision_price :integer
#  resaled               :integer
#  returns               :boolean          default("返品不可"), not null
#  returns_comment       :string
#  search_keywords       :text             default(""), not null
#  sell_type             :integer          default(0), not null
#  shipping_comment      :string
#  shipping_no           :integer
#  shipping_type         :integer
#  shipping_user         :integer          default("落札者"), not null
#  soft_destroyed_at     :datetime
#  star                  :integer
#  start_price           :integer
#  state                 :integer          default("中古"), not null
#  state_comment         :string
#  stock                 :integer
#  suspend               :datetime
#  template              :boolean          default(FALSE), not null
#  watches_count         :integer          default(0), not null
#  year                  :string           default(""), not null
#  youtube               :string           default(""), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  category_id           :bigint           not null
#  dst_id                :integer
#  machinelife_id        :integer
#  max_bid_id            :integer
#  user_id               :bigint           not null
#
# Indexes
#
#  index_products_on_category_id        (category_id)
#  index_products_on_soft_destroyed_at  (soft_destroyed_at)
#  index_products_on_user_id            (user_id)
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
