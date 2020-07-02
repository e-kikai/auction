class ApplicationRecord < ActiveRecord::Base
  before_save :normalize_changed_attributes

  self.abstract_class = true

  if Rails.env == "staging"
    establish_connection(:staging)
  end

  private

  # string, textで変更のあったカラムを変換
  def normalize_changed_attributes
    # attributes.each do |key, _|
    changed_attributes.each do |key, _|
      next if key.in?(%w|note encrypted_password|)
      self[key] = Charwidth.normalize(self[key]) if self[key].is_a?(String) && self[key].present?
    end
  end
end
