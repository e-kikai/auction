# == Schema Information
#
# Table name: alerts
#
#  id                :bigint           not null, primary key
#  keywords          :text
#  name              :string           default("")
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
#  index_alerts_on_category_id        (category_id)
#  index_alerts_on_product_image_id   (product_image_id)
#  index_alerts_on_soft_destroyed_at  (soft_destroyed_at)
#  index_alerts_on_user_id            (user_id)
#

class Alert < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  # NEWS_DAYS  = 1.day # 新着期間
  # NEWS_LIMIT = 10    # 新着表示件数

  belongs_to :user
  belongs_to :category, required: false
  belongs_to :company,  class_name: "User", required: false

  ### 検索 ###
  def products
    products = Product.includes(:user, :category, :product_images).status(Product::STATUS[:start]).with_keywords(keywords.to_s.normalize_charwidth.strip)

    if category_id.present?
      category = Category.find(category_id)
      products = products.where(category_id: category.subtree_ids)
    end

    products = products.where(user_id: company_id) if company_id.present?

    products
  end

  ### 新着 ###
  # def news
  #   products.where(dulation_start: (Time.now - NEWS_DAYS)..Time.now).limit(NEWS_LIMIT)
  # end

  ### 新着アラート ###
  def self.scheduling
    Alert.includes(:user).all.each do |al|
      BidMailer.news(al).deliver if al.products.news.present?
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
