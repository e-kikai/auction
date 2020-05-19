# == Schema Information
#
# Table name: bids
#
#  id                :bigint           not null, primary key
#  amount            :integer          default(0), not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_bids_on_product_id         (product_id)
#  index_bids_on_soft_destroyed_at  (soft_destroyed_at)
#  index_bids_on_user_id            (user_id)
#

require 'rails_helper'

RSpec.describe Bid, type: :model do
  describe "for validate" do
    it { should validate_presence_of :product_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :amount }
  end
end
