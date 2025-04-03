class Page < ApplicationRecord
  
  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "id", "id_value", "slug", "title", "updated_at"]
  end

  validates :title, presence: true
  validates :content, presence: true
  end
  