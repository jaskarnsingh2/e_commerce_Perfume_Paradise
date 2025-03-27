class Admin::PagesController < ApplicationController
    before_action :set_about_page, only: [:edit, :update]
  
    def edit; end
  
    def update
      if @page.update(page_params)
        redirect_to about_path, notice: "About page updated successfully."
      else
        render :edit
      end
    end
  
    private
  
    def set_about_page
      @page = Page.find_or_create_by(title: "About Us")
    end
  
    def page_params
      params.require(:page).permit(:title, :content)
    end
  end
  