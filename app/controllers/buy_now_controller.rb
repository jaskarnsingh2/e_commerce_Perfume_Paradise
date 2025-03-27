class BuyNowController < ApplicationController
  before_action :set_product

  STRIPE_SUPPORTED_COUNTRIES = ["US", "CA", "GB", "AU", "BY", "EC", "GE", "ID", "MX", "OM","RU","RS","VN","TZ"]
  def show; end

  def create
    begin
      session = Stripe::Checkout::Session.create({
        ui_mode: 'embedded',
        line_items: [{
          price_data: {
            currency: "usd",
            unit_amount: (@product.price * 100).to_i,
            product_data: {
              name: @product.name
            },
          },
          quantity: 1,
        }],
        shipping_address_collection: {
          allowed_countries: STRIPE_SUPPORTED_COUNTRIES
        },
        mode: 'payment',
        return_url: success_product_buy_now_url(@product),
      })

      render json: { clientSecret: session.client_secret }
      
    rescue => e
      # Log the error for debugging purposes
      Rails.logger.error "Stripe error: #{e.message}"
      # Render a JSON error response
      render json: { error: "There was an issue processing your payment. Please try again." }, status: :internal_server_error
    end
  end

  def success; end

  private

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end
end
