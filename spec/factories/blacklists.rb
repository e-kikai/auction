# == Schema Information
#
# Table name: blacklists
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :blacklist do
    
  end
end
