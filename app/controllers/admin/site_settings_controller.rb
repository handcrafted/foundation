class Admin::SiteSettingsController < AdminController
  # before_filter :find_site # inherited from application.rb
  
  def edit
    
  end

  def update
    respond_to do |format|
      if @site.update_attributes(params[:site_setting])
        flash[:notice] = "Your site settings have been updated."
        format.html { redirect_to edit_admin_site_setting_path }
      else
        flash[:warning] = "Your site settings couldn't be saved."
        format.html { render :action => :edit }
      end
    end
  end


end
