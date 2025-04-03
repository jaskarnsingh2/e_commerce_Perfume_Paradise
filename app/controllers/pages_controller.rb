# class PagesController < ApplicationController
#   def about
#     @page = Page.find_by(slug: 'about')

#     # If @page is nil, create a new page with a slug and content
#     if @page.nil?
#       @page = Page.create(title: "About Perfume Paradise", content: "Default About Page Content", slug: "about")
#     end
#   end # <-- This 'end' closes the about method
  
#   def contact
#     @contact_info = ContactInfo.first || ContactInfo.new(email: "perfumeparadise@paradise.ca", phone: "(204) 555-SCENT")
#   end
# end
class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug])
    # If page doesn't exist, return 404 or create a default page
    if @page.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
    end
  end
end
