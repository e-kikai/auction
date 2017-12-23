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
#  bank                   :string
#  bank_branch            :string
#  bank_account_type      :integer
#  bank_account_number    :string
#  bank_account_hodler    :string
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
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  soft_deletable
  default_scope { without_soft_destroyed }

  has_many   :products
  has_many   :bids
  has_many   :bid_products, through: :bids, source: :product
  has_many   :watches
  has_many   :watch_products, through: :watches, source: :product
  has_many   :follows
  has_many   :follow_users, through: :follows, source: :to_user
  has_many   :followers, foreign_key: :to_user_id, class_name: "Follow"
  has_many   :follower_users, through: :followers, source: :user

  has_many   :blacklists
  has_many   :blacklist_users, through: :blacklists, source: :to_user

  # accepts_nested_attributes_for :watches

  validates :bank_account_type, inclusion: {in: Product.states.keys}, allow_blank: true
  validates :allow_mail, inclusion: {in: [true, false]}
  validates :seller,     inclusion: {in: [true, false]}

  enum bank_account_type: { "普通" => 100, "当座" => 200 }


end
