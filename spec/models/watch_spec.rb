# == Schema Information
#
# Table name: watches
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  product_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Watch, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
