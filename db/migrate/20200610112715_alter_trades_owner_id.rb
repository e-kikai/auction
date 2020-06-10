class AlterTradesOwnerId < ActiveRecord::Migration[5.2]
  def change
    add_reference :trades, :owner, foreign_key: { to_table: :users }
  end
end
