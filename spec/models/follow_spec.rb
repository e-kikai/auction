# == Schema Information
#
# Table name: follows
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  to_user_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
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
