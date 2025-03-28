require 'httparty'
require 'uri'
require 'open-uri'
require 'faker'

Province.create([
  { name: "Ontario", abbreviation: "ON" },
  { name: "British Columbia", abbreviation: "BC" },
  { name: "Quebec", abbreviation: "QC" },
  { name: "Alberta", abbreviation: "AB" },
  { name: "Manitoba", abbreviation: "MB" },
  { name: "Saskatchewan", abbreviation: "SK" },
  { name: "Nova Scotia", abbreviation: "NS" },
  { name: "New Brunswick", abbreviation: "NB" },
  { name: "Prince Edward Island", abbreviation: "PE" },
  { name: "Newfoundland and Labrador", abbreviation: "NL" },
  { name: "Northwest Territories", abbreviation: "NT" },
  { name: "Yukon", abbreviation: "YT" },
  { name: "Nunavut", abbreviation: "NU" }
])


API_KEY = 'SWS5V1NFBdXIrTVgyQej7hId696CgbnlvmQmvtZq7Ef7ZwmTs646GaIF'
ENDPOINT = 'https://api.pexels.com/v1/search'

# Ensure categories exist
brands = ["Christian Dior", "Gucci", "COCO Chanel", "Versace"]
brands.each do |brand|
  Category.find_or_create_by!(name: brand)
end

# Seed products with Faker and associate images from Pexels
Category.all.each do |category|
  25.times do
    product_name = Faker::Commerce.product_name
    product_description = Faker::Lorem.sentence(word_count: 10)
    product_price = Faker::Commerce.price(range: 50..300)

    product = Product.create!(
      name: product_name,
      description: product_description,
      price: product_price,
      category: category
    )

    # Fetch perfume-related images from Pexels
    response = HTTParty.get(ENDPOINT, 
                           headers: { "Authorization" => API_KEY }, 
                           query: { query: 'perfume', per_page: 5 })

    if response.success?
      # Select a random image from the fetched photos
      random_photo = response.parsed_response['photos'].sample
      image_url = random_photo['src']['original']

      begin
        io = URI.open(image_url)
        # Attach the image to the product (assuming you have ActiveStorage set up)
        product.images.attach(io: io, filename: "#{product.name.downcase.parameterize}.jpg", content_type: "image/jpeg")
      rescue StandardError => e
        Rails.logger.error "Failed to attach image for product #{product.name}: #{e.message}"
      end
    else
      Rails.logger.error "Error fetching Pexels data: #{response.body}"
    end
  end
end
