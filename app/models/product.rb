class Product < ApplicationRecord
  has_rich_text :description
  has_many_attached :images
  belongs_to :category, optional: true
  has_many :cart_items
  attribute :on_sale, :boolean, default: false
  has_many :order_items
  has_many :orders, through: :order_items

  # Explicitly list all searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id name price quantity on_sale sale_price discount_percentage created_at updated_at category_id]
  end
  
  # Explicitly list all searchable associations
  def self.ransackable_associations(auth_object = nil)
    %w[category cart_items order_items orders]
  end

  # Include PgSearch for full-text search
  include PgSearch::Model
  
  # Define a pg_search_scope to search by name and rich text description
  pg_search_scope :search_by_name_and_description,
    against: :name,
    associated_against: { rich_text_description: :body },
    using: {
      tsearch: { prefix: true } # Enables partial word matching
    }

  # Validations
  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sale_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :discount_percentage, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100 
  }, allow_nil: true

  # Sale-related methods
  def on_sale?
    on_sale && (sale_price.present? || discount_percentage.present?)
  end

  def current_price
    on_sale? ? calculated_sale_price : price
  end

  private

  def calculated_sale_price
    if sale_price.present?
      sale_price
    elsif discount_percentage.present?
      price * (1 - discount_percentage.to_f / 100)
    else
      price
    end
  end
end