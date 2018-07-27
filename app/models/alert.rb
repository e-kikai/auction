# == Schema Information
#
# Table name: alerts
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  category_id       :bigint(8)
#  product_image_id  :bigint(8)
#  keywords          :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Alert < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  TOPPAGE_COUNT = 12 # 新着表示数

  belongs_to :user
  belongs_to :category,      required: false
  belongs_to :company,       class_name: "User", required: false

  # 検索
  def products
    search = Product.status(Product::STATUS[:start]).with_keywords(keywords)

    if category_id.present?
      category = Category.find(category_id)
      search = search.result.search(category_id_in: category.subtree_ids)
      
    end

    search.result
  end

end
