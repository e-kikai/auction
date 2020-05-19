# == Schema Information
#
# Table name: blacklists
#
#  id                :bigint           not null, primary key
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  to_user_id        :integer          not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_blacklists_on_soft_destroyed_at  (soft_destroyed_at)
#  index_blacklists_on_to_user_id         (to_user_id)
#  index_blacklists_on_user_id            (user_id)
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
