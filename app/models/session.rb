class Session < ActiveRecord::Base
  def self.sweep(old = 1.year)
    where("updated_at < '#{old.ago}'").delete_all
  end
end