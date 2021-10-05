class AlterProductsNameCollate < ActiveRecord::Migration[5.2]
  def change
    execute 'alter table products alter COLUMN name type varchar(255) collate "ja_JP.utf8";'
  end
end
