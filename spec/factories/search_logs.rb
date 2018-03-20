# == Schema Information
#
# Table name: search_logs
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  category_id :integer
#  company_id  :integer
#  keywords    :string
#  search_id   :integer
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
