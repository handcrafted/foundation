require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SiteSettingsController do
  fixtures :users
  
  before(:each) do
    set_session_for(Factory.create(:admin_user))
    @site = mock_model(SiteSetting)
    SiteSetting.should_receive(:find).and_return(@site)
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      @site.should_receive(:update_attributes).and_return(true)
      put 'update'
      flash[:notice] = "Your site settings have been updated."
      response.should redirect_to(edit_admin_site_setting_path)
    end
    
    it "should re-render edit on update failure" do
      @site.should_receive(:update_attributes).and_return(false)
      put 'update'
      flash[:warning] = "Your site settings couldn't be saved."
      response.should render_template("admin/site_settings/edit")
    end
    
  end
end
