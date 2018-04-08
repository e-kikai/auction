class ChangeMachinelifeId < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :machinelife_id, :machinelife_company_id
  end
end
