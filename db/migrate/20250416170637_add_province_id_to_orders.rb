class AddProvinceIdToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :province_id, :integer
  end
end
