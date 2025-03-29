class Page < ApplicationRecord
    has_rich_text :content
  

    validates :slug, uniqueness: true
  validates :title, :content, presence: true
  end
  