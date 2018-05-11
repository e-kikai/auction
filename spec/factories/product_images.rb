# == Schema Information
#
# Table name: product_images
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  image      :text             not null
#  order_no   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :product_image do
    
  end
end
