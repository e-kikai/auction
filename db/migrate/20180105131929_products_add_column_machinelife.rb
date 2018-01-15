class ProductsAddColumnMachinelife < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :machinelife_id,     :integer
    add_column :products, :machinelife_images, :string
  end
end
