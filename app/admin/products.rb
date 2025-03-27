ActiveAdmin.register Product do
  permit_params :name, :description, :price, :category_id, images: []

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :price
    column :category
    column "Images" do |product|
      # Iterate through each attached image and display them
      if product.images.attached?
        product.images.each do |image|
          # Display each image with a thumbnail
          image_tag image.variant(resize: "100x100").processed, alt: product.name
        end
      else
        "No images available"
      end
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :category, as: :select, collection: Category.all
      f.input :images, as: :file, input_html: { multiple: true }
    end
    f.actions
  end
end
