# == Schema Information
#
# Table name: abtests
#
#  id                :bigint           not null, primary key
#  host              :string
#  ip                :string
#  label             :string           not null
#  segment           :integer          not null
#  soft_destroyed_at :datetime
#  status            :integer          default(0), not null
#  utag              :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint
#
# Indexes
#
#  index_abtests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_abtests_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :abtest do
    
  end
end
