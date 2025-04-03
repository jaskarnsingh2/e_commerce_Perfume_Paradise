class HomeController < ApplicationController
  def index
    @products = Product.limit(8) # Fetch 8 products for display
  end
  
    def about
      @about_page = Page.find_by(title: "About Us")
    end
    
  end
  