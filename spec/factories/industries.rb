# == Schema Information
#
# Table name: industries
#
#  id                :bigint           not null, primary key
#  name              :string           default(""), not null
#  order_no          :integer          default(9999999), not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_industries_on_soft_destroyed_at  (soft_destroyed_at)
#

FactoryBot.define do
  factory :industry do
    
  end
end
