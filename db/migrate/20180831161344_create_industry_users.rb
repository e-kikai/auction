class CreateIndustryUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :industry_users do |t|
      t.belongs_to :user,     index: true, foreign_key: true
      t.belongs_to :industry, index: true, foreign_key: true

      t.timestamps
    end
  end
end
