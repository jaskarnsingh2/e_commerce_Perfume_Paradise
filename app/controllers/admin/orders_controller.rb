class Admin::OrdersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @orders = Order.includes(:user, :products).order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
  end
end