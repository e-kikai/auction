# == Schema Information
#
# Table name: abtests
#
#  id                :bigint           not null, primary key
#  finished_at       :datetime
#  label             :string           not null
#  segment           :string           not null
#  soft_destroyed_at :datetime
#  utag              :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_abtests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_abtests_on_utag_and_label     (utag,label) UNIQUE
#
FactoryBot.define do
  factory :abtest do
    
  end
end
