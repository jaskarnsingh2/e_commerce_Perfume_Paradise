class PagesController < ApplicationController
  def about
    @page = Page.find_by(slug: 'about') || Page.new(title: "About Perfume Paradise", content: "Default About Page Content")
  end

  def contact
    @contact_info = ContactInfo.first || ContactInfo.new(email: "perfumeparadise@paradise.ca", phone: "(204) 555-SCENT")
  end
end
