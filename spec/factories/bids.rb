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

FactoryBot.define do
  factory :bid do
    user
    product
  end
end
