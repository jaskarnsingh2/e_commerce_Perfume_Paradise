class CustomersController < ApplicationController
    before_action :authenticate_user!
    
    def update
      @customer = current_user.customer || current_user.build_customer
      
      if @customer.update(customer_params)
        render json: { success: true }
      else
        render json: { success: false, message: @customer.errors.full_messages.join(', ') }
      end
    end
    
    private
    
    def customer_params
      params.require(:customer).permit(:first_name, :last_name, :email, :phone, :address, :city, :province, :postal_code)
    end
  end