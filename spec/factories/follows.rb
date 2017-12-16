# == Schema Information
#
# Table name: follows
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :follow do
    
  end
end
