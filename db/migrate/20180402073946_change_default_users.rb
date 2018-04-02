class ChangeDefaultUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :allow_mail, true
  end
end
