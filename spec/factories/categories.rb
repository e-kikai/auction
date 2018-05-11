# == Schema Information
#
# Table name: categories
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  ancestry          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  order_no          :integer          default(999999999), not null
#  search_order_no   :string           default(""), not null
#

FactoryBot.define do
  factory :category do
    id       1
    name     "カテゴリ名"
    order_no 100
  end
end
