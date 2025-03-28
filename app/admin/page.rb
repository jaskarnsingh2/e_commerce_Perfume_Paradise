# app/admin/pages.rb (note the plural)
ActiveAdmin.register Page, as: "ContentPage" do
    # Specify which attributes can be mass-assigned
    permit_params :title, :slug, :content
  
    # Customize the index view
    index do
      selectable_column
      id_column
      column :title
      column :slug
      column :created_at
      actions
    end
  
    # Customize the form
    form do |f|
      f.inputs "Page Details" do
        f.input :title
        f.input :slug, 
                hint: "Used in URL. Use lowercase, no spaces (e.g., 'about-us', 'contact-page')"
        f.input :content, as: :rich_text
      end
      f.actions
    end
  
    # Optional: Add a show view
    show do
      attributes_table do
        row :title
        row :slug
        row :content do
          page.content
        end
        row :created_at
        row :updated_at
      end
    end
  end