# == Schema Information
#
# Table name: requests
#
#  id                :bigint           not null, primary key
#  detail            :text             default("")
#  display           :boolean          default(FALSE)
#  host              :string
#  ip                :string
#  name              :string           not null
#  soft_destroyed_at :datetime
#  ua                :string
#  utag              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_requests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_requests_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Request, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
