# == Schema Information
#
# Table name: shipping_labels
#
#  id                                                              :integer          not null, primary key
#  user_id                                                         :integer
#  shipping_no                                                     :integer
#  created_at                                                      :datetime         not null
#  updated_at                                                      :datetime         not null
#  name                                                            :string
#  #<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition :string
#

require 'rails_helper'

RSpec.describe ShippingLabel, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
