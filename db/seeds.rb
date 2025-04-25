require 'httparty'
require 'uri'
require 'open-uri'
require 'faker'

# Create provinces with their tax rates
provinces_data = [
  { name: "Alberta", abbreviation: "AB", gst: 5.0, pst: 0.0, hst: 0.0 },
  { name: "British Columbia", abbreviation: "BC", gst: 5.0, pste: 7.0, hst: 0.0 },
  { name: "Manitoba", abbreviation: "MB", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0.0 },
  { name: "New Brunswick", abbreviation: "NB", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Newfoundland and Labrador", abbreviation: "NL", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Northwest Territories", abbreviation: "NT", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 },
  { name: "Nova Scotia", abbreviation: "NS", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Nunavut", abbreviation: "NU", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 },
  { name: "Ontario", abbreviation: "ON", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 13.0 },
  { name: "Prince Edward Island", abbreviation: "PE", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Quebec", abbreviation: "QC", gst_rate: 5.0, pst_rate: 9.975, hst_rate: 0.0 },
  { name: "Saskatchewan", abbreviation: "SK", gst_rate: 5.0, pst_rate: 6.0, hst_rate: 0.0 },
  { name: "Yukon", abbreviation: "YT", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 }
]

provinces_data.each do |province_data|
  Province.find_or_create_by!(name: province_data[:name]) do |province|
    province.abbreviation = province_data[:abbreviation]
    province.gst_rate = province_data[:gst_rate]
    province.pst_rate = province_data[:pst_rate]
    province.hst_rate = province_data[:hst_rate]
  end
end


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
