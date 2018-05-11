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

class ProductImage < ApplicationRecord
  IMAGE_NUM     = 20
  NOIMAGE_THUMB = "noimage.png"

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
