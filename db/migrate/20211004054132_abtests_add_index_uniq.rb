class AbtestsAddIndexUniq < ActiveRecord::Migration[5.2]
  def change
    add_column    :abtests, :finished_at, :datetime

    change_column :abtests, :segment, :string, null: false

    remove_column :abtests, :status
    remove_column :abtests, :user_id
    remove_column :abtests, :ip
    remove_column :abtests, :host

    add_index     :abtests, [:utag, :label], unique: true
  end
end
