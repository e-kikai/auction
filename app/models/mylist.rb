# == Schema Information
#
# Table name: mylists
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  product_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Mylist < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user
  belongs_to :product

  validates :user_id,    presence: true
  validates :product_id, presence: true
end
