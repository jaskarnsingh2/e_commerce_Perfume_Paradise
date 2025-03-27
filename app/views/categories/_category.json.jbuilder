json.extract! category, :id, :name, :description, :images, :created_at, :updated_at
json.url category_url(category, format: :json)
json.description category.description.to_s
json.images url_for(category.images)
