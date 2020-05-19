# == Schema Information
#
# Table name: product_images
#
#  id         :bigint           not null, primary key
#  image      :text             not null
#  order_no   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_images_on_product_id  (product_id)
#

FactoryBot.define do
  factory :product_image do
    
  end
end
