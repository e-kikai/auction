# == Schema Information
#
# Table name: bids
#
#  id                :integer          not null, primary key
#  product_id        :integer
#  user_id           :integer
#  amount            :integer
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

  private

  # def validate_amount
  #   errors[:amount] << ("が#{open.rate.to_s(:delimited)}円単位ではありません")          if amount.to_i % open.rate > 0
  #   errors[:amount] << ("が#{product.min_price.to_s(:delimited)}円未満になっています")  if amount.to_i < product.
  # end
end
