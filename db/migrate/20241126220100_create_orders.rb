class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total
      t.decimal :tax_total
      t.decimal :grand_total
      t.string :status

      t.timestamps
    end
  end
end
