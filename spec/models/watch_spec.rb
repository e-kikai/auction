# == Schema Information
#
# Table name: watches
#
#  id                :bigint           not null, primary key
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_watches_on_product_id         (product_id)
#  index_watches_on_soft_destroyed_at  (soft_destroyed_at)
#  index_watches_on_user_id            (user_id)
#

require 'rails_helper'

RSpec.describe Watch, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
