# == Schema Information
#
# Table name: search_logs
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  category_id :bigint(8)
#  company_id  :integer
#  keywords    :string
#  search_id   :bigint(8)
#  ip          :string
#  host        :string
#  referer     :string
#  ua          :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :search_log do
    
  end
end
