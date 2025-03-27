# app/models/order_item.rb
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Calculate the total price for this item (quantity * price)
  before_save :calculate_total

  def calculate_total
    self.total = self.quantity * self.price
  end

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
