# == Schema Information
#
# Table name: follows
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Follow < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  PRODUCTS_NUM = 5

  belongs_to :user
  belongs_to :to_user, class_name: "User"

  validates :user_id,    presence: true
  validates :to_user_id, presence: true

  validates :to_user_id, uniqueness: { message: "は、既にフォローリストに登録されています。", scope: [:user_id, :soft_destroyed_at] }
end
