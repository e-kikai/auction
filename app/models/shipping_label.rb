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

class ShippingLabel < ApplicationRecord
end
