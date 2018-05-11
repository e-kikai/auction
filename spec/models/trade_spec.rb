# == Schema Information
#
# Table name: trades
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)
#  user_id           :bigint(8)
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Trade, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
