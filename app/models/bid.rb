# == Schema Information
#
# Table name: bids
#
#  id                :integer          not null, primary key
#  product_id        :integer          not null
#  user_id           :integer          not null
#  amount            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Bid < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user
  belongs_to :product

  scope :result_order, -> { order(amount: :desc, created_at: :asc) }

  validates :amount, presence: true, numericality: { only_integer: true }

  validate :validate_amount

  private

  def validate_amount
    if product.bids_count > 0 && amount.to_i < product.max_price + product.bid_unit
      errors[:amount] << ("は、現在金額より#{product.bid_unit}円以上高値を入力してください")
    elsif amount.to_i < product.max_price
      errors[:amount] << ("は、現在金額より高値を入力してください")
    end
  end
end
