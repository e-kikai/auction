# == Schema Information
#
# Table name: blacklists
#
#  id                :bigint           not null, primary key
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  to_user_id        :integer          not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_blacklists_on_soft_destroyed_at  (soft_destroyed_at)
#  index_blacklists_on_to_user_id         (to_user_id)
#  index_blacklists_on_user_id            (user_id)
#

require 'rails_helper'

RSpec.describe Blacklist, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
