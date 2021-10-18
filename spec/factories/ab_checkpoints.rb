# == Schema Information
#
# Table name: ab_checkpoints
#
#  id                :bigint           not null, primary key
#  key               :string           not null
#  soft_destroyed_at :datetime
#  value             :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  abtest_id         :bigint
#  product_id        :bigint
#
# Indexes
#
#  index_ab_checkpoints_on_abtest_id          (abtest_id)
#  index_ab_checkpoints_on_product_id         (product_id)
#  index_ab_checkpoints_on_soft_destroyed_at  (soft_destroyed_at)
#
# Foreign Keys
#
#  fk_rails_...  (abtest_id => abtests.id)
#  fk_rails_...  (product_id => products.id)
#
FactoryBot.define do
  factory :ab_checkpoint do
    
  end
end
