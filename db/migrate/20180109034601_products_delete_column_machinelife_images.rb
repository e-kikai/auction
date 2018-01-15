class ProductsDeleteColumnMachinelifeImages < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :machinelife_images
  end
end
