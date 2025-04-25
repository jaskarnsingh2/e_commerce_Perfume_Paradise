class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def past_orders
    @orders = current_user.orders.where(status: "completed")
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  # 👉 New checkout page
  # def new
  #   logger.debug("Current Cart: #{@current_cart.inspect}")
  #   if @current_cart.nil? || @current_cart.cart_items.empty?
  #     redirect_to root_path, alert: "Your cart is empty."
  #     return
  #   end
  
  #   @order = Order.new
  #   @customer = current_user.customer || Customer.new
  #   @cart = @current_cart  # 💥 Add this line!
  #   @cart_items = @current_cart.cart_items
  # end
  def new
    @order = Order.new
    
    # Get the selected province (if any)
    province_id = params[:order]&.[](:province_id)
    @province = province_id.present? ? Province.find(province_id) : Province.find_by(name: "Ontario")
    
    # Calculate cart subtotal
    @subtotal = @current_cart.cart_items.sum { |item| item.product.price * item.quantity }
    
    # Calculate initial taxes
    @pst_amount = @subtotal * (@province.pst || 0) / 100
    @gst_amount = @subtotal * (@province.gst || 0) / 100
    @hst_amount = @subtotal * (@province.hst || 0) / 100
    @total_tax = @pst_amount + @gst_amount + @hst_amount
    @total = @subtotal + @total_tax
    
    @cart_items = @current_cart.cart_items
  end
  
  def create
  Rails.logger.info("Starting order creation")
  Rails.logger.info("Params: #{params.inspect}")
  
  @order = current_user.orders.build(order_params)
  
  # Additional order data
  @order.subtotal = params[:order][:subtotal]
  @order.tax_amount = params[:order][:tax_amount]
  @order.shipping_cost = params[:order][:shipping_cost]
  @order.total = @order.subtotal.to_f + @order.tax_amount.to_f + @order.shipping_cost.to_f
  @order.status = "pending"
  
  Rails.logger.info("Order built: #{@order.inspect}")
  
  # Create order items from cart items
  cart = current_cart
  if cart && cart.cart_items.any?
    cart.cart_items.each do |item|
      @order.order_items.build(
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.product.price,
        total: item.quantity * item.product.price
      )
    end
    
    Rails.logger.info("Added #{@order.order_items.size} items to order")
    
    if @order.save
      Rails.logger.info("Order saved successfully with ID: #{@order.id}")
      
      # Clear the cart
      cart.cart_items.destroy_all
      
      # Redirect to payment page
      redirect_to payment_page_path(@order)
      return
    else
      Rails.logger.error("Failed to save order: #{@order.errors.full_messages}")
      flash.now[:alert] = "There was a problem creating your order: #{@order.errors.full_messages.join(', ')}"
      
      # Set up view variables for rendering
      @province = Province.find_by(id: params[:order][:province_id])
      @cart_items = cart.cart_items
      @cart_subtotal = cart.cart_items.sum { |item| item.quantity * item.product.price }
      @shipping_cost = 0
      @tax_amount = params[:order][:tax_amount].to_f
      @tax_display = params[:order][:tax_display]
      @cart_total = @cart_subtotal + @tax_amount + @shipping_cost
      
      render :new, status: :unprocessable_entity
    end
  else
    Rails.logger.error("Cart is empty")
    flash[:alert] = "Your cart is empty"
    redirect_to root_path
  end
rescue => e
  Rails.logger.error("Error in order creation: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
  flash[:error] = "An unexpected error occurred"
  redirect_to root_path
end
  private

  
  def set_cart
    if session[:cart_secret_id].present?
      @current_cart = Cart.find_by(secret_id: session[:cart_secret_id]) # Use cart_secret_id for finding the cart
    else
      @current_cart = Cart.create # Create a new cart if it doesn't exist
      session[:cart_secret_id] = @current_cart.secret_id # Store the secret_id in the session
    end
  end
  

  # def order_params
  #   # Update to include shipping_cost if your Order model has this field
  #   params.require(:order).permit(:province_id, :shipping_cost).merge(address: params[:address])
  # end
  def order_params
    params.require(:order).permit(:province_id, :shipping_cost)
  end
end
