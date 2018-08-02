class AlertsAddColumnName < ActiveRecord::Migration[5.2]
  def change
    add_column :alerts, :name, :string, nill: false, default: ""
  end
end
