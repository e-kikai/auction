class CreateCompanyChats < ActiveRecord::Migration[5.2]
  def change
    create_table :company_chats do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :res, foreign_key: { to_table: :company_chats }
      t.text       :comment

      t.timestamps
      t.datetime :soft_destroyed_at, index: true

    end
  end
end
