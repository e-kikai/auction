# == Schema Information
#
# Table name: categories
#
#  id                :integer          not null, primary key
#  name              :string
#  ancestry          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  soft_destroyed_at :datetime
#  order_no          :integer          default(999999999), not null
#  search_order_no   :string           default(""), not null
#

require 'rails_helper'

describe Category do
  let(:category) { create(:category) }

  example "名前について" do
    expect(category.name).to eq "カテゴリ名"
  end
end
