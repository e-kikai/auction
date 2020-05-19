# == Schema Information
#
# Table name: shipping_labels
#
#  id                                                              :bigint           not null, primary key
#  #<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition :string
#  name                                                            :string
#  shipping_no                                                     :integer
#  created_at                                                      :datetime         not null
#  updated_at                                                      :datetime         not null
#  user_id                                                         :bigint
#
# Indexes
#
#  index_shipping_labels_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe ShippingLabel, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
