# == Schema Information
#
# Table name: result_logs
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)
#  bid_id_id         :bigint(8)
#  result_at         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

class ResultLog < ApplicationRecord
  belongs_to :product, required: true
  belongs_to :bid,     required: false
end
