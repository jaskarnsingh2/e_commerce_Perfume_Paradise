ActiveAdmin.register Page do
  permit_params :title, :content, :slug

  # The index page where pages are listed
  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :created_at
    column :updated_at
    actions
  end

  # The show page for individual pages
  show do
    attributes_table do
      row :title
      row :slug
      row :content
      row :created_at
      row :updated_at
    end
  end

  # The form for editing/creating pages
  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :content, as: :text  # Textarea for content
      f.input :slug
    end
    f.actions
  end
end
