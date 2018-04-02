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
#  international_shipping :string
#  delivery_date          :integer          default("1〜2で発送"), not null
#  state                  :integer          default("中古"), not null
#  state_comment          :string
#  returns                :boolean          default(FALSE), not null
#  returns_comment        :string
#  auto_extension         :boolean          default(FALSE), not null
#  early_termination      :boolean          default(FALSE), not null
#  auto_resale            :integer          default(0)
#  resaled                :integer
#  lower_price            :integer
#  special_featured       :boolean          default(FALSE), not null
#  special_bold           :boolean          default(FALSE), not null
#  special_bgcolor        :boolean          default(FALSE), not null
#  special_icon           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  soft_destroyed_at      :datetime
#  max_price              :integer          default(0)
#  bids_count             :integer          default(0)
#  max_bid_id             :integer
#  fee                    :integer
#  code                   :string
#  template               :boolean          default(FALSE), not null
#  machinelife_id         :integer
#  machinelife_images     :text
#  shipping_no            :integer
#  cancel                 :text
#  hashtags               :text             default(""), not null
#  star                   :integer
#  note                   :text
#  watches_count          :integer          default(0), not null
#  detail_logs_count      :integer          default(0), not null
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
