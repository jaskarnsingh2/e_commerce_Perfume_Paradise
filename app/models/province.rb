class Province < ApplicationRecord
    has_many :users
  
    validates :name, presence: true
    validates :abbreviation, presence: true
  end
  