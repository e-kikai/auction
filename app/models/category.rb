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
#

class Category < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_ancestry

  has_many :products

  scope :root_categories, -> { where(ancestry: nil) }
end
