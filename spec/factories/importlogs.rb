# == Schema Information
#
# Table name: importlogs
#
#  id         :bigint           not null, primary key
#  code       :string
#  message    :text
#  status     :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_importlogs_on_product_id  (product_id)
#  index_importlogs_on_user_id     (user_id)
#

FactoryBot.define do
  factory :importlog do
    
  end
end
