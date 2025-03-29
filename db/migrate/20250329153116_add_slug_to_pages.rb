class AddSlugToPages < ActiveRecord::Migration[7.2]
  def change
    add_column :pages, :slug, :string
  end
end
