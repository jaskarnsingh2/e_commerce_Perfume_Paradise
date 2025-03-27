class AddAddressToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :province, :string
    add_column :users, :zip_code, :string
  end
end
