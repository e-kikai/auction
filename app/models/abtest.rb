# == Schema Information
#
# Table name: abtests
#
#  id                :bigint           not null, primary key
#  host              :string
#  ip                :string
#  label             :string           not null
#  segment           :integer          not null
#  soft_destroyed_at :datetime
#  status            :integer          default(0), not null
#  utag              :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint
#
# Indexes
#
#  index_abtests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_abtests_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Abtest < ApplicationRecord

  enum rate: { start: 0, finish: 1 }

  ### テスト開始 ###
  def self.start(label, *vars)
    # セグメント設定
    return false unless session[:utag]
    unless session.dig(:ab, label)
      session[:ab] ||= {}
      session[:ab][label] = (session[:utag].ord % vars.length).to_i

      self.create(
        user_id: user_signed_in? ? current_user.id : nil,
        utag:    session[:utag],
        ip:      ip,
        label:   label,
        segment: session[:ab][label],
        status:  :start,
      )
    end

    vars.at(session[:ab][label])
  end

  ### コンバージョン ###
  def self.finish(label)
    return false unless session[:utag] || session.dig(:ab, label)
    self.create(
      user_id: user_signed_in? ? current_user.id : nil,
      utag:    session[:utag],
      ip:      ip,
      label:   label,
      segment: session[:ab][label],
      status:  :finish,
    )
  end

  private

  ### セグメント生成・格納 ###
  def self.calc_segment

    session[:utag].ord / vars
  end
end
