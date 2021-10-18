class AbCheckpointRemoveNullFalse < ActiveRecord::Migration[5.2]
  def change
    change_column :ab_checkpoints, :value, :integer, null: true, default: nil
  end
end
