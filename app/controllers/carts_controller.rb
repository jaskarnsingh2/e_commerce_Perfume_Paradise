class CartsController < ApplicationController
  before_action :set_product, only: [:create, :destroy]
  before_action :set_cart
  before_action :set_cart_item, only: [:show, :update_cart_item, :destroy]
  before_action :authenticate_user! # Ensure the user is authenticated

  def create
    cart_item = @current_cart.cart_items.find_by(product_id: @product.id)

    if cart_item
      cart_item.quantity += 1
      cart_item.save
    else
      @current_cart.cart_items.create(product_id: @product.id, quantity: 1)
    end

    redirect_to cart_path(@current_cart.secret_id), notice: 'Item added to cart.'
  end

  def show
    # Displays the cart using @current_cart
  end

  # def checkout
  #   @order = Order.new
  #   @customer = current_user.customer || current_user.create_customer
  #   @cart_items = @current_cart.cart_items
    
  #   # Check if there are cart items
  #   if @cart_items.empty?
  #     redirect_to cart_path(@current_cart.secret_id), alert: 'Your cart is empty.'
  #     return # Add this explicit return to prevent further execution
  #   end
    
  #   # If you want to pre-fill order information
  #   @order.user_id = current_user.id
  #   @order.total = @cart_items.sum { |item| item.quantity * item.product.price }
  # end

  def checkout
    @order = Order.new
    @cart_items = @current_cart.cart_items
    
    # Check if there are cart items
    if @cart_items.empty?
      redirect_to cart_path(@current_cart.secret_id), alert: 'Your cart is empty.'
      return
    end
  end

  def update_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
    if @cart_item.update(cart_item_params)
      redirect_to cart_path(@current_cart.secret_id), notice: "Cart updated successfully"
    else
      render :show, alert: "Failed to update the cart item"
    end
  end
  


  def destroy
    @cart_item = @current_cart.cart_items.find_by(product_id: params[:product_id])

    if @cart_item
      @cart_item.destroy
      redirect_to cart_path(@current_cart.secret_id), notice: 'Item removed from cart.'
    else
      redirect_to cart_path(@current_cart.secret_id), alert: 'Item not found in cart.'
    end
  end

  STRIPE_SUPPORTED_COUNTRIES = ["US", "CA", "GB", "AU", "BY", "EC", "GE", "ID", "MX", "OM", "RU", "RS", "VN", "TZ"]

  # def stripe_session
  #   line_items = @current_cart.cart_items.map do |cart_item|
  #     {
  #       price_data: {
  #         currency: "usd",
  #         unit_amount: (cart_item.product.price * 100).to_i,
  #         product_data: {
  #           name: cart_item.product.name,
  #         },
  #       },
  #       quantity: cart_item.quantity,
  #     }
  #   end

  #   session = Stripe::Checkout::Session.create({
  #     ui_mode: 'embedded',
  #     line_items: line_items,
  #     shipping_address_collection: {
  #       allowed_countries: STRIPE_SUPPORTED_COUNTRIES
  #     },
  #     mode: 'payment',
  #     automatic_tax: { enabled: true },
  #     return_url: success_cart_url(@current_cart.secret_id),
  #   })

  #   render json: { clientSecret: session.client_secret }
  # end

  def stripe_session
    line_items = @current_cart.cart_items.map do |cart_item|
      {
        price_data: {
          currency: "usd",
          unit_amount: (cart_item.product.price * 100).to_i,
          product_data: {
            name: cart_item.product.name,
          },
        },
        quantity: cart_item.quantity,
      }
    end
    
    session = Stripe::Checkout::Session.create({
      ui_mode: 'embedded',
      line_items: line_items,
      shipping_address_collection: {
        allowed_countries: STRIPE_SUPPORTED_COUNTRIES
      },
      mode: 'payment',
      automatic_tax: { enabled: true },
      return_url: success_cart_url(@current_cart.secret_id),
    })
    
    render json: { clientSecret: session.client_secret }
  end

  # def success
  #   if @current_cart.cart_items.any?
  #     session[:cart_secret_id] = nil
  #   end

  #   @purchased_cart = Cart.find_by(secret_id: params[:id])
  #   redirect_to root_path unless @purchased_cart
  # end

  def success
    @purchased_cart = Cart.find_by(secret_id: params[:id])
    
    if @purchased_cart && @purchased_cart.cart_items.any?
      subtotal = @purchased_cart.cart_items.sum { |item| item.quantity * item.product.price }
      
      # Tax calculation based on province
      province = current_user.customer&.province
      gst_rate = 0.05  # 5% GST
      pst_rate = province == "BC" ? 0.07 : 0  # Example: 7% PST in BC
      hst_rate = province == "ON" ? 0.13 : 0  # Example: 13% HST in Ontario
      
      gst = subtotal * gst_rate
      pst = subtotal * pst_rate
      hst = subtotal * hst_rate
      
      total_tax = gst + pst + hst
      total = subtotal + total_tax
      
      # Create order
      @order = Order.create(
        user_id: current_user.id,
        customer_id: current_user.customer.id,
        status: "processing",
        subtotal: subtotal,
        gst: gst,
        pst: pst,
        hst: hst,
        total: total
      )
      
      # Create order items
      @purchased_cart.cart_items.each do |cart_item|
        @order.order_items.create(
          product_id: cart_item.product_id,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end
      
      # Clear the cart
      session[:cart_secret_id] = nil
      @purchased_cart.cart_items.destroy_all
      
      flash[:notice] = "Your order has been placed successfully!"
    else
      flash[:alert] = "Your cart is empty."
    end
    
    redirect_to root_path
  end
  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_cart
    if session[:cart_secret_id]
      @current_cart = Cart.find_by(secret_id: session[:cart_secret_id])
    end

    unless @current_cart
      @current_cart = Cart.create
      session[:cart_secret_id] = @current_cart.secret_id
    end
  end

  def set_cart_item
    @cart_item = @current_cart.cart_items.find_by(id: params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
