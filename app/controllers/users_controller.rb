class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def update
    if current_user.update(user_params)
      render json: { success: true }
    else
      render json: { success: false, message: current_user.errors.full_messages.join(', ') }
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :address, :city, :province, :zip_code)
  end
end