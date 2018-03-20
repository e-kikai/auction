# == Schema Information
#
# Table name: toppage_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  ip         :string
#  host       :string
#  referer    :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :toppage_log do
    
  end
end
