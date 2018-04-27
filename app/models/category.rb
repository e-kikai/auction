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
#  search_order_no   :string           default(""), not null
#

class Category < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_ancestry

  has_many :products

  ### validates ###
  validates :name,     presence: true
  validates :order_no, presence: true

  ### callback ###
  before_save :make_path_order_no

  def ancestor_names
    ancestors.map{ |g| g.name }.join(" > ")
  end

  def self.options
    # categories = Category.all.order(:ancestry, :order_no).index_by(&:id)
    categories = Category.all.order(:search_order_no).select(:id, :name, :ancestry).index_by(&:id)

    categories.map do |i, ca|
      [ca.path_ids.map { |v| categories[v].name rescue "" }.join(" > ") + "0", i]
    end
  end

  def make_path_order_no
    self.search_order_no = path.map { |c| sprintf("%010d", c.order_no) }.join("/")
    self
  end
end
