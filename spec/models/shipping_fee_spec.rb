# == Schema Information
#
# Table name: shipping_fees
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shipping_no :integer
#  addr_1      :string
#  price       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe ShippingFee, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end