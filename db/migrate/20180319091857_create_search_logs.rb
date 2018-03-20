class CreateSearchLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :search_logs do |t|
      t.belongs_to :user,    index: true

      t.belongs_to :category
      t.integer    :company_id
      t.string     :keywords

      t.belongs_to :search

      t.string     :ip
      t.string     :host
      t.string     :referer
      t.string     :ua

      t.timestamps
    end
  end

  add_column :detail_logs, :referer, :string
end
