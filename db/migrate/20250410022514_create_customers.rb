class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :address
      t.string :city
      t.string :zip_code

      t.timestamps
    end
  end
end
