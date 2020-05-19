# == Schema Information
#
# Table name: trades
#
#  id                :bigint           not null, primary key
#  comment           :text
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_trades_on_product_id         (product_id)
#  index_trades_on_soft_destroyed_at  (soft_destroyed_at)
#  index_trades_on_user_id            (user_id)
#

require 'rails_helper'

RSpec.describe Trade, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
