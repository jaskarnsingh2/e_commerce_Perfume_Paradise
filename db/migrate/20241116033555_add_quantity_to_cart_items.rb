class AddQuantityToCartItems < ActiveRecord::Migration[7.2]
  def change
    add_column :cart_items, :quantity, :integer
  end
end
