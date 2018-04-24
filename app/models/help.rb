# == Schema Information
#
# Table name: helps
#
#  id                :integer          not null, primary key
#  title             :string           default(""), not null
#  content           :text             default(""), not null
#  target            :integer          default("ユーザ"), not null
#  order_no          :integer          default(999999999), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  uid               :string           default(""), not null
#

class Help < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  ### validates ###
  validates :title,    presence: true
  validates :content,  presence: true
  validates :target,   presence: true
  validates :order_no, presence: true, numericality: { only_integer: true, greater_than: 0 }

  ### enum ###
  enum target: { "ユーザ" => 0, "出品会社" => 100 }

end
