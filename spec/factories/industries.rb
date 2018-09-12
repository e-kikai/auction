# == Schema Information
#
# Table name: industries
#
#  id                :bigint(8)        not null, primary key
#  name              :string           default(""), not null
#  order_no          :integer          default(9999999), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

FactoryBot.define do
  factory :industry do
    
  end
end
