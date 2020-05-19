# == Schema Information
#
# Table name: searches
#
#  id                :bigint           not null, primary key
#  description       :text             default("")
#  keywords          :text
#  name              :string
#  publish           :boolean
#  q                 :text
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category_id       :bigint
#  company_id        :integer
#  product_image_id  :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_searches_on_category_id        (category_id)
#  index_searches_on_product_image_id   (product_image_id)
#  index_searches_on_soft_destroyed_at  (soft_destroyed_at)
#  index_searches_on_user_id            (user_id)
#

class Search < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  TOPPAGE_COUNT = 12 # 新着表示数

  belongs_to :user
  belongs_to :category,      required: false
  belongs_to :company,       class_name: "User", required: false
  belongs_to :product_image, required: false

  ### validates ###
  validates :name, presence: true

  # URI生成
  def q_parse
    JSON.parse(q, quirks_mode: true) rescue {}
  end

  def uri
    # "/products?#{{ keywords: keywords, category_id: category_id, company_id: company_id, q: q_parse, search_id: id}.to_query}"
    "/searches/#{id}"
  end

  def params
    {
      keywords:    keywords,
      category_id: category_id,
      company_id:  company_id,
      q:           q_parse,
      search_id:   nil
    }
  end

  # 検索
  def products
    search = Product.status(Product::STATUS[:start]).with_keywords(keywords.to_s.normalize_charwidth.strip).search(q)

    if category_id.present?
      category = Category.find(category_id)
      search = search.result.search(category_id_in: category.subtree_ids)
    end

    if company_id.present?
      search = search.result.search(user_id_eq: company_id)
    end

    search.result
  end
end
