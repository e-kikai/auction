# == Schema Information
#
# Table name: shipping_labels
#
#  id                                                              :bigint(8)        not null, primary key
#  user_id                                                         :bigint(8)
#  shipping_no                                                     :integer
#  created_at                                                      :datetime         not null
#  updated_at                                                      :datetime         not null
#  name                                                            :string
#  #<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition :string
#

class ShippingLabel < ApplicationRecord
end
