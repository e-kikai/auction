# == Schema Information
#
# Table name: follows
#
#  id                :bigint           not null, primary key
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  to_user_id        :integer          not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_follows_on_soft_destroyed_at  (soft_destroyed_at)
#  index_follows_on_to_user_id         (to_user_id)
#  index_follows_on_user_id            (user_id)
#

require 'rails_helper'

# describe Follow do
#   pending "add some examples to (or delete) #{__FILE__}"
# end

describe '四則演算' do
  it '1 + 1 は 2 になること' do
    expect(1 + 1).to eq 2
  end
  it '10 - 1 は 9 になること' do
    expect(10 - 1).to eq 9
  end
end
