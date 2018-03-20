# == Schema Information
#
# Table name: detail_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
#  ip         :string
#  host       :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  referer    :string
#

require 'rails_helper'

RSpec.describe DetailLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
