# == Schema Information
#
# Table name: blacklists
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  to_user_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Blacklist, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
