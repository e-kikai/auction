# == Schema Information
#
# Table name: infos
#
#  id                :bigint           not null, primary key
#  content           :text             default(""), not null
#  soft_destroyed_at :datetime
#  start_at          :datetime         not null
#  target            :integer          default("ユーザ"), not null
#  title             :string           default(""), not null
#  uid               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_infos_on_soft_destroyed_at  (soft_destroyed_at)
#  index_infos_on_uid                (uid) UNIQUE
#

class Info < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  ### validates ###
  validates :title,    presence: true
  validates :content,  presence: true
  validates :target,   presence: true
  validates :start_at, presence: true

  ### enum ###
  enum target: { "ユーザ" => 0, "出品会社" => 100 }
end
