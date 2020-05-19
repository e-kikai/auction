# == Schema Information
#
# Table name: helps
#
#  id                :bigint           not null, primary key
#  content           :text             default(""), not null
#  order_no          :integer          default(999999999), not null
#  soft_destroyed_at :datetime
#  target            :integer          default("ユーザ"), not null
#  title             :string           default(""), not null
#  uid               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_helps_on_soft_destroyed_at  (soft_destroyed_at)
#  index_helps_on_uid                (uid) UNIQUE
#

FactoryBot.define do
  factory :help do
    
  end
end
