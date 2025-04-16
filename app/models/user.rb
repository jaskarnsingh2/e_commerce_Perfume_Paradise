class User < ApplicationRecord
  has_one :customer
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
        
   has_many :orders
   belongs_to :province

   validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
   validates :password, presence: true, length: { minimum: 6 }
   validates :address, presence: true
   validates :province_id, presence: true

end
