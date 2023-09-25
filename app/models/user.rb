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

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  mount_uploader :header_image, HeaderImageUploader

  soft_deletable
  default_scope { without_soft_destroyed }

  has_many   :products
  has_many   :bids
  has_many   :bid_products, -> { distinct(:product_id) }, through: :bids, source: :product
  has_many   :watches
  has_many   :watch_products, through: :watches, source: :product
  has_many   :follows
  has_many   :follow_users, through: :follows, source: :to_user
  has_many   :followers, foreign_key: :to_user_id, class_name: "Follow"
  has_many   :follower_users, through: :followers, source: :user
  has_many   :requests

  has_many   :blacklists
  has_many   :blacklist_users, through: :blacklists, source: :to_user

  has_many   :importlogs
  has_many   :trades
  has_many   :searches
  has_many   :alerts

  has_many   :industry_users, dependent: :destroy
  has_many   :industries,     through:   :industry_users

  accepts_nested_attributes_for :industry_users, allow_destroy: true
  # accepts_nested_attributes_for :watches

  validates :allow_mail, inclusion: {in: [true, false]}
  validates :seller,     inclusion: {in: [true, false]}

  _validators.delete(:email)
  _validate_callbacks.each do |callback|
    if callback.raw_filter.respond_to? :attributes
      callback.raw_filter.attributes.delete :email
    end
  end

  # emailのバリデーションを定義し直す
  validates :email, presence: true
  validates_format_of :email, with: Devise.email_regexp, if: :email_changed?
  validates_uniqueness_of :email, scope: :soft_destroyed_at, if: :email_changed?

  ### SCOPE ###
  scope :companies, -> { where(seller: true) }

  ### CALLBACK ###
  before_save :init_account
  after_create :mailmagazine_create
  after_update :mailmagazine_update

  def count_star
    products.where.not(star: nil).count
  end

  def count_star_good
    products.where("star >= 4").count
  end

  def count_star_bad
    products.where("star <= 2").count
  end

  def blacklisted_count
    Blacklist.where(to_user_id: id).count
  end

  def self.find_for_authentication(warden_conditions)
    without_soft_destroyed.where(email: warden_conditions[:email]).first
  end

  def self.companies_selector
    user_ids = Product.status(Product::STATUS[:start]).select(:user_id)
    where(seller: true, id: user_ids).order(:id).pluck(:company, :id)
  end

  def company_remove_kabu
    company.gsub(/(株式会社|有限会社|\(株\)|\(有\))/, "")
  end

  ### ウォッチリストIDリスト ###
  def watch_ids
    watches.pluck(:product_id)
  end

  def watch?(product_id)
    @watche_ids = watches.pluck(:product_id) if @watche_ids.nil?

    @watche_ids.include?(product_id)
  end

  private

  def init_account
    self.account = SecureRandom.urlsafe_base64(6) if self.account.blank?
  end

  def mailmagazine_create
    if self.allow_mail
      mm = MailMagazine.new
      mm.add_member(self, email)
    end
  rescue => e
  end

  def mailmagazine_update
    if saved_change_to_allow_mail?
      mm = MailMagazine.new

      if self.allow_mail
        mm.add_member(self, email)
      else
        # mm.remove_member(email) if mm.member?(email)
        mm.remove_member(email)
      end
    end
  rescue => e
  end
end
