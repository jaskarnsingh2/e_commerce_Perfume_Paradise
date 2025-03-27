class OrdersController < ApplicationController
  before_action :authenticate_user!

  def past_orders
    @orders = current_user.orders.where(status: "completed")  # Only show completed orders
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
