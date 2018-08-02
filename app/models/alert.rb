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
#  company_id        :integer
#  name              :string           default("")
#

class Alert < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  NEWS_DAYS  = 1.day # 新着期間
  NEWS_LIMIT = 10    # 新着表示件数

  belongs_to :user
  belongs_to :category, required: false
  belongs_to :company,  class_name: "User", required: false

  ### 検索 ###
  def products
    products = Product.includes(:user, :category).status(Product::STATUS[:start]).with_keywords(keywords.to_s.normalize_charwidth.strip)

    if category_id.present?
      category = Category.find(category_id)
      products = products.where(category_id: category.subtree_ids)
    end

    products = products.where(user_id: company_id) if company_id.present?

    products
  end

  ### 新着 ###
  def news
    products.where(dulation_start: (Time.now - NEWS_DAYS)..Time.now).limit(NEWS_LIMIT)
  end

  ### 新着アラート ###
  def self.scheduling
    Alert.includes(:user).all.each do |al|
      if al.news.present?
        BidMailer.news(al).deliver
      end
    end
  end

  def params
    {
      keywords:    keywords,
      category_id: category_id,
      company_id:  company_id
    }
  end

  def uri
    "/products?#{params.to_query}"
  end

end
