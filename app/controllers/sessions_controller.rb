class SessionsController < ApplicationController
  def destroy
    sign_out(current_user) # Devise handles the sign out
    redirect_to root_path, notice: 'You have successfully signed out.'
  end
end
