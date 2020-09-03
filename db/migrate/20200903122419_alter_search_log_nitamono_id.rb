class AlterSearchLogNitamonoId < ActiveRecord::Migration[5.2]
  def change
    add_column :search_logs, :nitamono_product_id , :bigint
  end
end
