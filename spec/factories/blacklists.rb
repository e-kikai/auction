# == Schema Information
#
# Table name: blacklists
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  to_user_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :blacklist do
    
  end
end
