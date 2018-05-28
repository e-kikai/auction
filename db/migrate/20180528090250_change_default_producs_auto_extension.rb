class ChangeDefaultProducsAutoExtension < ActiveRecord::Migration[5.2]
  def change
    change_column_default :products, :auto_extension, true
  end
end
