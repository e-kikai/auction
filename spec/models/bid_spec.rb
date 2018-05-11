# == Schema Information
#
# Table name: bids
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)        not null
#  user_id           :bigint(8)        not null
#  amount            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Bid, type: :model do
  describe "for validate" do
    it { should validate_presence_of :product_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :amount }
  end
end
