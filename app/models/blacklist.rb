# == Schema Information
#
# Table name: blacklists
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Blacklist < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user
  belongs_to :to_user, class_name: "User"

  validates :user_id,    presence: true
  validates :to_user_id, presence: true

  validates :to_user_id, uniqueness: { message: "は、既にブラックリストに登録されています。", scope: [:user_id, :soft_destroyed_at] }
end
