# == Schema Information
#
# Table name: product_images
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  image      :text             not null
#  order_no   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductImage < ApplicationRecord
  IMAGE_NUM = 10

  mount_uploader :image, ProductImageUploader

  belongs_to :product

  # validate :product_images_number_of_product

  private

  # def product_images_number_of_product
  #   if product && product.product_images.count > IMAGE_NUM
  #     errors.add(:product_image, " : 画像ファイルの数は1商品に#{IMAGE_NUM}枚までです")
  #   end
  # end
end
