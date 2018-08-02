class AlertsAddColumnCompanyId < ActiveRecord::Migration[5.2]
  def change
    add_column :alerts, :company_id, :integer
  end
end
