# == Schema Information
#
# Table name: helps
#
#  id                :bigint           not null, primary key
#  content           :text             default(""), not null
#  order_no          :integer          default(999999999), not null
#  soft_destroyed_at :datetime
#  target            :integer          default("ユーザ"), not null
#  title             :string           default(""), not null
#  uid               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_helps_on_soft_destroyed_at  (soft_destroyed_at)
#  index_helps_on_uid                (uid) UNIQUE
#

class Help < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  NEWS_LIMIT = 10 # 新着表示件数

  ### validates ###
  validates :title,    presence: true
  validates :content,  presence: true
  validates :target,   presence: true
  validates :order_no, presence: true, numericality: { only_integer: true, greater_than: 0 }

  ### enum ###
  enum target: { "ユーザ" => 0, "出品会社" => 100 }

end
