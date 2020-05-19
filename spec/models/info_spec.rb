# == Schema Information
#
# Table name: infos
#
#  id                :bigint           not null, primary key
#  content           :text             default(""), not null
#  soft_destroyed_at :datetime
#  start_at          :datetime         not null
#  target            :integer          default("ユーザ"), not null
#  title             :string           default(""), not null
#  uid               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_infos_on_soft_destroyed_at  (soft_destroyed_at)
#  index_infos_on_uid                (uid) UNIQUE
#

require 'rails_helper'

RSpec.describe Info, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
