class PagesController < ApplicationController
  layout :custom_layout
  
  def index
    redirect_to page_path("home")
  end

  def show
    id = params[:id]
    page_id = id.blank? ? 'pages/home' : "pages/#{id}"
    @partial_title = id.blank? ? "Home" : id
    if File.exists?("app/views/#{page_id}.html.haml")
      render :template => page_id
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find the page #{page_id}"
    end
  end
  
  private
  
  def custom_layout
    "application"
  end
  
end