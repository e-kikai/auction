# == Schema Information
#
# Table name: helps
#
#  id                :integer          not null, primary key
#  title             :string           default(""), not null
#  content           :text             default(""), not null
#  target            :integer          default("ユーザ"), not null
#  order_no          :integer          default(999999999), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#

require 'rails_helper'

RSpec.describe Help, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
