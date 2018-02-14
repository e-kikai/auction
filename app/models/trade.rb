# == Schema Information
#
# Table name: trades
#
#  id                :integer          not null, primary key
#  product_id        :integer
#  user_id           :integer
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Trade < ApplicationRecord
  soft_deletable

  belongs_to :product
  belongs_to :user
end
