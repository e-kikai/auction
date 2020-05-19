# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  account                :string
#  addr_1                 :string
#  addr_2                 :string
#  addr_3                 :string
#  allow_mail             :boolean          default(TRUE), not null
#  bank                   :text
#  birthday               :string
#  business_hours         :string
#  charge                 :string
#  company                :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  contact_name           :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  fax                    :string
#  header_image           :text
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  license                :string
#  name                   :string
#  note                   :text
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  result_message         :text             default(""), not null
#  seller                 :boolean          default(FALSE), not null
#  sign_in_count          :integer          default(0), not null
#  soft_destroyed_at      :datetime
#  special                :boolean          default(FALSE)
#  tel                    :string
#  unconfirmed_email      :string
#  url                    :string
#  zip                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  machinelife_company_id :integer
#
# Indexes
#
#  index_users_on_email_and_soft_destroyed_at  (email,soft_destroyed_at) UNIQUE
#  index_users_on_reset_password_token         (reset_password_token) UNIQUE
#  index_users_on_soft_destroyed_at            (soft_destroyed_at)
#

FactoryBot.define do
  factory :user do
    # id       1
    # name     "ユーザ名"
    #
    # sequence :email do |i|
    #   "test#{i}@test.com"
    # end
    # password "testtest"
    # password_confirmation "testtest"
    # encrypted_password "testtest"
  end
end
