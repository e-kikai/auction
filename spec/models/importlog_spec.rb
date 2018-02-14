# == Schema Information
#
# Table name: importlogs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
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
