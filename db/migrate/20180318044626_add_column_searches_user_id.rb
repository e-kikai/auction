class AddColumnSearchesUserId < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :company_id, :integer
  end
end
