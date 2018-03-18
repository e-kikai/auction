# == Schema Information
#
# Table name: searches
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  category_id       :integer
#  product_image_id  :integer
#  name              :string
#  keywords          :text
#  q                 :text
#  publish           :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Search < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user
  belongs_to :category,      required: false
  belongs_to :company,       class_name: "User", required: false
  belongs_to :product_image, required: false

  ### validates ###
  validates :name,        presence: true

  # URI生成
  def q_parse
    JSON.parse(q, quirks_mode: true) rescue {}
  end

  def uri
    "/products?#{{ keywords: keywords, category_id: category_id, company_id: company_id, q: q_parse, search_id: id}.to_query}"
  end

  # 検索
  def products
    search = Product.status(Product::STATUS[:start]).with_keywords(keywords).search(q)

    if category_id.present?
      category = Category.find(category_id)
      search = search.result.search(category_id_in: category.subtree_ids)
    end

    search.result
  end

end
