# == Schema Information
#
# Table name: shipping_fees
#
#  id          :bigint           not null, primary key
#  addr_1      :string
#  price       :integer
#  shipping_no :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_shipping_fees_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe ShippingFee, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
