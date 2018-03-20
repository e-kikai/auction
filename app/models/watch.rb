# == Schema Information
#
# Table name: watches
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  product_id        :integer          not null
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

end
