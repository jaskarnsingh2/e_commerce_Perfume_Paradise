ActiveAdmin.register Product do
  permit_params :name, :description, :price, :category_id, images: []

  # Only declare filters you actually want to use
  filter :name
  filter :category
  filter :price
  filter :on_sale
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :price
    column :category
    column "Images" do |product|
      if product.images.attached?
        product.images.map do |image|
          begin
            image_tag image.variant(resize_to_limit: [100, 100]), 
                      alt: product.name, 
                      class: 'admin-product-thumbnail'
          rescue StandardError => e
            Rails.logger.error "Image processing error: #{e.message}"
            "Error processing image"
          end
        end.compact.join.html_safe
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