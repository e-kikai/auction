# == Schema Information
#
# Table name: trades
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)
#  user_id           :bigint(8)
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :trade do
    
  end
end
