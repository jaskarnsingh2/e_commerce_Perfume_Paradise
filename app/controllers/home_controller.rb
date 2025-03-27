class HomeController < ApplicationController
    def index
      # Add any logic needed for the Home page
    end
  
    def about
      @about_page = Page.find_by(title: "About Us")
    end
  end
  