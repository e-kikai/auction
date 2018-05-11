# == Schema Information
#
# Table name: follows
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :follow do
    
  end
end
