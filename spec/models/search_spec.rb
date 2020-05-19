# == Schema Information
#
# Table name: searches
#
#  id                :bigint           not null, primary key
#  description       :text             default("")
#  keywords          :text
#  name              :string
#  publish           :boolean
#  q                 :text
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category_id       :bigint
#  company_id        :integer
#  product_image_id  :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_searches_on_category_id        (category_id)
#  index_searches_on_product_image_id   (product_image_id)
#  index_searches_on_soft_destroyed_at  (soft_destroyed_at)
#  index_searches_on_user_id            (user_id)
#

require 'rails_helper'

RSpec.describe Search, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
