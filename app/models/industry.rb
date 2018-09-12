# == Schema Information
#
# Table name: industries
#
#  id                :bigint(8)        not null, primary key
#  name              :string           default(""), not null
#  order_no          :integer          default(9999999), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class Industry < ApplicationRecord
  soft_deletable

  has_many   :industry_users
  has_many   :users, through: :industry_users
end
