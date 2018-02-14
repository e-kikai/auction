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

FactoryBot.define do
  factory :shipping_label do
    
  end
end
