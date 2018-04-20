# == Schema Information
#
# Table name: infos
#
#  id                :integer          not null, primary key
#  title             :string           default(""), not null
#  content           :text             default(""), not null
#  target            :integer          default("ユーザ"), not null
#  start_at          :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
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
