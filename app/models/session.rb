# == Schema Information
#
# Table name: sessions
#
#  id         :bigint           not null, primary key
#  data       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  session_id :string           not null
#
# Indexes
#
#  index_sessions_on_session_id  (session_id) UNIQUE
#  index_sessions_on_updated_at  (updated_at)
#
class Session < ActiveRecord::Base
  ### 古いセッションデータをクリア ###
  def self.sweep(old = 1.year)
    where("updated_at < '#{old.ago}'").delete_all
  end
end
