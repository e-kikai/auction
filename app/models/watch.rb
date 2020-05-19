# == Schema Information
#
# Table name: watches
#
#  id                :bigint           not null, primary key
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_watches_on_product_id         (product_id)
#  index_watches_on_soft_destroyed_at  (soft_destroyed_at)
#  index_watches_on_user_id            (user_id)
#

class Watch < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user
  belongs_to :product
  counter_culture :product

  validates :user_id,    presence: true
  validates :product_id, presence: true

  validates :product_id, uniqueness: { message: "は、既にウォッチリストに登録されています。", scope: [:user_id, :soft_destroyed_at] }

  ### ウォッチおすすめ新着メール配信 ###
  def self.scheduling
    User.includes(:watches, :bids).all.each do |us|
      next if us.watches.length == 0 && us.bids.length == 0

      base = Product.where(id: us.watches.pluck(:product_id).concat(us.bids.pluck(:product_id)))

      products = Product.related_products(base).news.limit(Product::NEWS_LIMIT)
      next if products.blank?

      BidMailer.watch_news(us, products).deliver
    end
  end
end
