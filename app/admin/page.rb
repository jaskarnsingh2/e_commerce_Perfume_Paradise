ActiveAdmin.register Page do
  permit_params :title, :content, :slug

  form do |f|
    f.inputs do
      f.input :slug, as: :select, collection: ['about', 'contact'], include_blank: false
      f.input :title
      f.input :content, as: :quill_editor
    end
    f.actions
  end
end
