# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account                :string
#  name                   :string
#  zip                    :string
#  birthday               :string
#  allow_mail             :boolean          default(FALSE), not null
#  seller                 :boolean          default(FALSE), not null
#  company                :string
#  contact_name           :string
#  addr_1                 :string
#  addr_2                 :string
#  addr_3                 :string
#  tel                    :string
#  bank                   :text
#  bank_branch            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  soft_destroyed_at      :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  charge                 :string
#  fax                    :string
#  url                    :string
#  license                :string
#  business_hours         :string
#  note                   :text
#

FactoryBot.define do
  factory :user do
    id       1
    name     "ユーザ名"

    sequence :email do |i|
      "test#{i}@test.com"
    end
    password "testtest"
    password_confirmation "testtest"
    encrypted_password "testtest"
  end
end
