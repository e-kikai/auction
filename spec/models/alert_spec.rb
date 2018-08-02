# == Schema Information
#
# Table name: alerts
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  category_id       :bigint(8)
#  product_image_id  :bigint(8)
#  keywords          :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  company_id        :integer
#  name              :string           default("")
#

require 'rails_helper'

RSpec.describe Alert, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
