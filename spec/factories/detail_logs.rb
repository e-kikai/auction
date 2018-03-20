# == Schema Information
#
# Table name: detail_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
#  ip         :string
#  host       :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  referer    :string
#

FactoryBot.define do
  factory :detail_log do
    
  end
end
