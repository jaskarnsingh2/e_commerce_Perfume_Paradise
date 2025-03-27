# app/controllers/users_controller.rb

class UsersController < ApplicationController
    before_action :authenticate_user!
  
    def show
      # Fetch user profile details
      @user = current_user
  
      # Fetch past orders (completed orders) for the user
      @orders = current_user.orders.where(status: "completed")
    end
  end
  