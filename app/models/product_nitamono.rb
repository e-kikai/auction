# == Schema Information
#
# Table name: product_nitamonos
#
#  id                :bigint           not null, primary key
#  norm              :float            not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  nitamono_id       :integer          not null
#  product_id        :bigint           not null
#
# Indexes
#
#  index_product_nitamonos_on_nitamono_id                 (nitamono_id)
#  index_product_nitamonos_on_product_id                  (product_id)
#  index_product_nitamonos_on_product_id_and_nitamono_id  (product_id,nitamono_id) UNIQUE
#  index_product_nitamonos_on_soft_destroyed_at           (soft_destroyed_at)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class ProductNitamono < ApplicationRecord
  belongs_to :product,                         required: true
  belongs_to :nitamono, class_name: "Product", required: true

  validates :product_id, uniqueness: { scope: :nitamono_id }
end
