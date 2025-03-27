class CartsController < ApplicationController
  before_action :set_product, only: [:create, :destroy]
  before_action :set_cart_item, only: [:show, :update_cart_item, :destroy]

  def create
    cart_item = @current_cart.cart_items.find_by(product_id: @product.id)

    if cart_item
      cart_item.quantity += 1
      cart_item.save
    else
      @current_cart.cart_items.create(product_id: @product.id, quantity: 1)
    end

    redirect_to cart_path(@current_cart), notice: 'Item added to cart.'
  end

  def show
    # Display the current cart
  end

   def update_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])

    # Update the cart item with the new quantity
    if @cart_item.update(cart_item_params)
      # Recalculate total items in the cart
      total_items = @current_cart.cart_items.sum(:quantity)

      # Optionally, update the cart's total price or other attributes
      # @current_cart.update(total_price: @current_cart.cart_items.sum(&:total_price))

      redirect_to cart_path(@current_cart.secret_id), notice: "Cart updated successfully"
    else
      render :show, alert: "Failed to update the cart item"
    end
  end

  def destroy
    @cart_item = @current_cart.cart_items.find_by(product_id: params[:product_id])
  
    if @cart_item
      @cart_item.destroy
      redirect_to cart_path(@current_cart), notice: 'Item removed from cart.'
    else
      redirect_to cart_path(@current_cart), alert: 'Item not found in cart.'
    end
  end
  
  STRIPE_SUPPORTED_COUNTRIES = ["US", "CA", "GB", "AU", "BY", "EC", "GE", "ID", "MX", "OM","RU","RS","VN","TZ"]
  
  def stripe_session
    line_items = @current_cart.cart_items.map do |cart_item|
      {
        price_data: {
          currency: "usd",
          unit_amount: (cart_item.product.price * 100).to_i,  # Convert price to cents
          product_data: {
            name: cart_item.product.name,
          },
        },
        quantity: cart_item.quantity,  # Set quantity for each product
      }
    end
  
    session = Stripe::Checkout::Session.create({
      ui_mode: 'embedded',  # Set ui_mode to 'embedded'
      line_items: line_items,  # Pass an array of line items, one per product
      shipping_address_collection: {
        allowed_countries: STRIPE_SUPPORTED_COUNTRIES
      },
      mode: 'payment',
      automatic_tax: { enabled: true },
      return_url: success_cart_url(@current_cart.secret_id),  # The return URL after the payment
    })
  
    render json: { clientSecret: session.client_secret }
  end  
  
  def success
    if @current_cart.cart_items.any?
      session[:current_cart_id] = nil
    end
    @purchased_cart = Cart.find_by_secret_id(params[:id])
    redirect_to root_path unless @purchased_cart
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_cart_item
    @cart_item = @current_cart.cart_items.find_by(id: params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
