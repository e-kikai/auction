# == Schema Information
#
# Table name: infos
#
#  id                :bigint(8)        not null, primary key
#  title             :string           default(""), not null
#  content           :text             default(""), not null
#  target            :integer          default("ユーザ"), not null
#  start_at          :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  uid               :string           default(""), not null
#

FactoryBot.define do
  factory :info do
    
  end
end