class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  # Callbacks to calculate totals
  before_save :calculate_totals
  
  def calculate_totals
    # Handle empty order_items case to avoid nil errors
    self.total = order_items.any? ? order_items.sum(&:total) : 0
    
    # Calculate taxes based on province rates
    if province
      gst_amount = self.total * (province.gst || 0) / 100  # Changed from gst_rate to gst
      pst_amount = self.total * (province.pst || 0) / 100  # Changed from pst_rate to pst
      hst_amount = self.total * (province.hst || 0) / 100  # Changed from hst_rate to hst
      
      self.tax_total = gst_amount + pst_amount + hst_amount
    else
      self.tax_total = 0
    end
    
    self.grand_total = self.total + self.tax_total
  end
  
  validates :grand_total, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_total, numericality: { greater_than_or_equal_to: 0 }
  
  # Helper methods for accessing specific tax amounts
  def gst_amount
    province ? self.total * (province.gst || 0) / 100 : 0  # Changed from gst_rate to gst
  end
  
  def pst_amount
    province ? self.total * (province.pst || 0) / 100 : 0  # Changed from pst_rate to pst
  end
  
  def hst_amount
    province ? self.total * (province.hst || 0) / 100 : 0  # Changed from hst_rate to hst
  end
end