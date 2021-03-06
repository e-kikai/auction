# == Schema Information
#
# Table name: bids
#
#  id                :bigint           not null, primary key
#  amount            :integer          default(0), not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_bids_on_product_id         (product_id)
#  index_bids_on_soft_destroyed_at  (soft_destroyed_at)
#  index_bids_on_user_id            (user_id)
#

class Bid < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  after_save :versus

  belongs_to :user
  belongs_to :product
  counter_culture :product

  scope :result_order, -> { order(amount: :desc, created_at: :asc) }

  validates :amount, presence: true, numericality: { only_integer: true }

  validate :validate_amount

  # 入札金額の消費税計算
  def amount_tax
    Product.calc_tax(amount)
  end

  def amount_with_tax
    Product.calc_price_with_tax(amount)
  end

  private

  def validate_amount
    if product.finished?
      errors[:base] << ("この商品は、入札期間は終了しています")
    elsif amount.blank?
      errors[:amount] << ("を入力してください")
    elsif product.bids_count > 0 && amount < product.max_price + product.bid_unit
      errors[:amount] << ("は、現在金額より#{product.bid_unit}円以上高値を入力してください")
    elsif amount < product.start_price
      errors[:amount] << ("は、現在金額より高値を入力してください")
    end
  end

  ### 現在の最高入札と入札金額を比較 ###
  def versus
    product.versus(self)
  end
end
