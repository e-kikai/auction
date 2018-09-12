# == Schema Information
#
# Table name: industry_users
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  industry_id :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class IndustryUser < ApplicationRecord
  belongs_to :user
  belongs_to :industry
end
