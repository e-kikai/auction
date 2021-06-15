# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint           not null, primary key
#  host       :string
#  ip         :string
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string
#  utag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_detail_logs_on_product_id  (product_id)
#  index_detail_logs_on_user_id     (user_id)
#

require 'rails_helper'

RSpec.describe DetailLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
