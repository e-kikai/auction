# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  product_id :bigint(8)
#  ip         :string
#  host       :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  referer    :string
#  r          :string           default(""), not null
#

FactoryBot.define do
  factory :detail_log do
    
  end
end
