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

require 'rails_helper'

RSpec.describe IndustryUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
