# == Schema Information
#
# Table name: mylists
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  product_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :mylist do
    
  end
end
