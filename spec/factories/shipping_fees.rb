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

FactoryBot.define do
  factory :shipping_fee do
    
  end
end
