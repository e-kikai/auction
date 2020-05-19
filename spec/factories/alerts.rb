# == Schema Information
#
# Table name: alerts
#
#  id                :bigint           not null, primary key
#  keywords          :text
#  name              :string           default("")
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
#  index_alerts_on_category_id        (category_id)
#  index_alerts_on_product_image_id   (product_image_id)
#  index_alerts_on_soft_destroyed_at  (soft_destroyed_at)
#  index_alerts_on_user_id            (user_id)
#

FactoryBot.define do
  factory :alert do
    
  end
end
