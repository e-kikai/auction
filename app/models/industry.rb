# == Schema Information
#
# Table name: industries
#
#  id                :bigint           not null, primary key
#  name              :string           default(""), not null
#  order_no          :integer          default(9999999), not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_industries_on_soft_destroyed_at  (soft_destroyed_at)
#

class Industry < ApplicationRecord
  soft_deletable

  has_many   :industry_users
  has_many   :users, through: :industry_users
end
