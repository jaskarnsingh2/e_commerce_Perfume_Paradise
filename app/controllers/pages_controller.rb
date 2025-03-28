class PagesController < ApplicationController
    def show
      # This can remain for other potential dynamic page rendering
    end
  
    def about
      # This will explicitly render the about page
       render 'about'
    end
    def contact
        # This action will render the Contact page
      end
  end