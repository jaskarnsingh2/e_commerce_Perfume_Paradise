class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Callbacks to calculate totals
  before_save :calculate_totals

  def calculate_totals
    self.total = order_items.sum(&:total)
    self.tax_total = self.total * 0.1 # Assuming 10% tax rate, can be modified
    self.grand_total = self.total + self.tax_total
  end
  validates :grand_total, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_total, numericality: { greater_than_or_equal_to: 0 }
end
