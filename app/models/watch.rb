# == Schema Information
#
# Table name: watches
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  product_id        :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
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
