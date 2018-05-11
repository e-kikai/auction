# == Schema Information
#
# Table name: importlogs
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  product_id :bigint(8)
#  status     :integer
#  code       :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  url        :string
#

require 'rails_helper'

RSpec.describe Importlog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
