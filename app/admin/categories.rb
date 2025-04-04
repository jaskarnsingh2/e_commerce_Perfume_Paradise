ActiveAdmin.register Category do
  permit_params :name, :description

  # Only include filters you actually want to use
  filter :name
  filter :products
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end
end