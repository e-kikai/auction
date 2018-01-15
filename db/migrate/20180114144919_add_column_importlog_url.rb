class AddColumnImportlogUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :importlogs, :url, :string
  end
end
