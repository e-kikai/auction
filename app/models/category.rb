# == Schema Information
#
# Table name: categories
#
#  id                :integer          not null, primary key
#  name              :string
#  ancestry          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  order_no          :integer          default(999999999), not null
#

class Category < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_ancestry

  has_many :products

  ### validates ###
  validates :name,     presence: true
  validates :order_no, presence: true

  def ancestor_names
    "/" + ancestors.map{ |g| g.name }.join("/")
  end
end
