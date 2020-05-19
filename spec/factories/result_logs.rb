# == Schema Information
#
# Table name: result_logs
#
#  id                :bigint           not null, primary key
#  result_at         :datetime
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  bid_id_id         :bigint
#  product_id        :bigint
#
# Indexes
#
#  index_result_logs_on_bid_id_id          (bid_id_id)
#  index_result_logs_on_product_id         (product_id)
#  index_result_logs_on_result_at          (result_at)
#  index_result_logs_on_soft_destroyed_at  (soft_destroyed_at)
#

FactoryBot.define do
  factory :result_log do
    
  end
end
