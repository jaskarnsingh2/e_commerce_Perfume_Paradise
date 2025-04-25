class PaymentsController < ApplicationController
    before_action :authenticate_user!  # Ensure user is logged in
    before_action :set_order
    
    def show
      Rails.logger.debug("Displaying payment page for order #{@order.id}")
      # This action will display the payment form
    end
    
    def process_payment
      Rails.logger.debug("Processing payment for order #{@order.id}")
      # This action will handle the payment submission
      # Add your payment processing logic here (e.g., Stripe, PayPal)
      
      if payment_successful?
        @order.update(status: 'paid')
        # You might want to send a confirmation email here
        redirect_to order_path(@order), notice: 'Payment successful!'
      else
        flash.now[:alert] = 'Payment failed. Please try again.'
        render :show
      end
    end
    
    private
    
    def set_order
      @order = Order.find(params[:id])
      Rails.logger.debug("Set order: #{@order.inspect}")
      
      # Ensure the order belongs to current user
      unless @order.user == current_user
        Rails.logger.warn("Unauthorized access attempt to order #{@order.id} by user #{current_user.id}")
        redirect_to root_path, alert: "You don't have permission to access this page"
      end
    end
    
    def payment_successful?
      # Implement your actual payment logic here
      # For now, just return true as a placeholder
      true
    end
  end