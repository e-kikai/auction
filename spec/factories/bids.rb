# == Schema Information
#
# Table name: bids
#
#  id                :integer          not null, primary key
#  product_id        :integer          not null
#  user_id           :integer          not null
#  amount            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :bid do
    user
    product
  end
end
