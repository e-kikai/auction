# == Schema Information
#
# Table name: abtests
#
#  id                :bigint           not null, primary key
#  finished_at       :datetime
#  label             :string           not null
#  segment           :string           not null
#  soft_destroyed_at :datetime
#  utag              :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_abtests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_abtests_on_utag_and_label     (utag,label) UNIQUE
#
class Abtest < ApplicationRecord
  # validates :utag, uniquness: { scope: [:label]  }

  ### テスト開始 ###
  def self.start(utag, label, *vars)
    return vars.first unless utag # UTAG未設定の場合はスキップ

    ### セグメントキー取得 ###
    segment = Abtest.get_segment(utag, label)

    ### セグメント初期設定(ログから均一) ###
    unless segment
      segment = Abtest.new_segment(label, vars) # 新規キー取得

      # セグメント保存
      self.create(
        utag:    utag,
        label:   label,
        segment: segment,
      )
    end

    segment
  rescue => e
    logger.debug e.message
    vars.first
  end

  ### コンバージョン ###
  def self.finish(utag, label)
    ### テスト取得 ###
    abtest = Abtest.find_by(utag: utag, label: label)

    ### 未スタート or すでにfinishしている場合はスキップ
    return false unless abtest || abtest.finished_at.present?

    # 結果を保存
    abtest.update(finished_at: Time.now)
  rescue => e
    logger.debug e.message
    false
  end

  private

  ### 新規セグメントキー取得 ###
  def self.new_segment(label, vars)
    last_segment = Abtest.where(label: label).order(id: :desc).limit(1).pluck(:segment).first
    last_key     = vars.map(&:to_s).index(last_segment.to_s)

    if last_key.present? && vars[last_key + 1]
      vars[last_key + 1]
    else
      vars.first
    end
  end

  ### セグメントキー取得 ###
  def self.get_segment(utag, label)
    Abtest.where(utag: utag, label: label).order(id: :desc).limit(1).pluck(:segment).first
  end
end
