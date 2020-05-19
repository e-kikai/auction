# == Schema Information
#
# Table name: industry_users
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  industry_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_industry_users_on_industry_id  (industry_id)
#  index_industry_users_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (industry_id => industries.id)
#  fk_rails_...  (user_id => users.id)
#

class IndustryUser < ApplicationRecord
  belongs_to :user
  belongs_to :industry
end
