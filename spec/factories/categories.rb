# == Schema Information
#
# Table name: categories
#
#  id                :bigint           not null, primary key
#  ancestry          :string
#  name              :string
#  order_no          :integer          default(999999999), not null
#  search_order_no   :string           default(""), not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_categories_on_ancestry           (ancestry)
#  index_categories_on_soft_destroyed_at  (soft_destroyed_at)
#

FactoryBot.define do
  factory :category do
    # id       1
    # name     "カテゴリ名"
    # order_no 100
  end
end
