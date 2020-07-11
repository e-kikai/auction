# == Schema Information
#
# Table name: company_chats
#
#  id                :bigint           not null, primary key
#  comment           :text
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  res_id            :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_company_chats_on_res_id             (res_id)
#  index_company_chats_on_soft_destroyed_at  (soft_destroyed_at)
#  index_company_chats_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (res_id => company_chats.id)
#
class CompanyChat < ApplicationRecord
  soft_deletable

  belongs_to :user
  belongs_to :res, class_name: "CompanyChat"
end
