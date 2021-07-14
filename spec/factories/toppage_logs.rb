# == Schema Information
#
# Table name: toppage_logs
#
#  id         :bigint           not null, primary key
#  host       :string
#  ip         :string
#  nonlogin   :boolean          default(TRUE)
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string
#  utag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_toppage_logs_on_user_id  (user_id)
#

FactoryBot.define do
  factory :toppage_log do
    
  end
end
