# == Schema Information
#
# Table name: watches
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  product_id        :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Watch, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
