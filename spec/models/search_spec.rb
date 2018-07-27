# == Schema Information
#
# Table name: searches
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  category_id       :bigint(8)
#  product_image_id  :bigint(8)
#  name              :string
#  keywords          :text
#  q                 :text
#  publish           :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  company_id        :integer
#  description       :text             default("")
#

require 'rails_helper'

RSpec.describe Search, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
