class AddStatusToCarts < ActiveRecord::Migration[7.2]
  def change
    add_column :carts, :status, :integer, default: 0
  end
end
