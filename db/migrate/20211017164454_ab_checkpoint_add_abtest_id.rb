class AbCheckpointAddAbtestId < ActiveRecord::Migration[5.2]
  def change
    add_reference :ab_checkpoints, :abtest, index: true, foreign_key: true

    remove_column :ab_checkpoints, :utag
    remove_column :ab_checkpoints, :label

    remove_foreign_key :ab_checkpoints, :users
    remove_reference   :ab_checkpoints, :user, index: true
  end
end
