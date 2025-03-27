class Category < ApplicationRecord
  has_rich_text :description
  has_one_attached :image
  has_many :products
  belongs_to :category, optional: true

# Define searchable attributes
def self.ransackable_attributes(auth_object = nil)
  %w[id name created_at updated_at]
end

# Define searchable associations
def self.ransackable_associations(auth_object = nil)
  %w[products] # Only include associations you want to be searchable
end

  validates :name, presence: true, uniqueness: true
end
