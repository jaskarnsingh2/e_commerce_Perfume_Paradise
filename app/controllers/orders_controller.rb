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
  def new
    logger.debug("Current Cart: #{@current_cart.inspect}")
    if @current_cart.nil? || @current_cart.cart_items.empty?
      redirect_to root_path, alert: "Your cart is empty."
      return
    end

    @order = Order.new
    @customer = current_user.customer || Customer.new
    @cart_items = @current_cart.cart_items
  end

  # 👉 Submitting the order
  def create
    @customer = current_user.customer || Customer.new(customer_params)
    @customer.user = current_user

    unless @customer.save
      flash[:alert] = "Error saving customer information."
      render :new and return
    end

    @order = current_user.orders.build(customer: @customer)
    @order.status = "completed"
    @order.save!

    @current_cart.cart_items.each do |item|
      @order.order_items.create!(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    # Empty the cart
    @current_cart.cart_items.destroy_all

    redirect_to order_path(@order), notice: "Your order was placed successfully!"
  end

  private

  def set_cart
    @current_cart = Cart.find_by(secret_id: session[:cart_secret_id])
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :address, :city, :postal_code, :province_id)
  end
end
