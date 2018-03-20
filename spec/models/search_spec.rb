# == Schema Information
#
# Table name: searches
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  category_id       :integer
#  product_image_id  :integer
#  name              :string
#  keywords          :text
#  q                 :text
#  publish           :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  company_id        :integer
#

require 'rails_helper'

RSpec.describe Search, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
