# == Schema Information
#
# Table name: blacklists
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  to_user_id        :integer
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
end
