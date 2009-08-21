require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::DashboardController do
  
  describe "with admin login" do
    before(:each) do
      unset_session
      set_session_for(Factory(:admin_user))
    end

    it "should load the dashboard" do
      get :show
      response.should be_success
    end
  end
  
  describe "without admin login" do
    before(:each) do
      unset_session
      Factory(:admin_user)
      set_session_for(Factory(:valid_user))
    end

    it "should not load the dashboard" do
      get :show
      response.should redirect_to(account_url)
    end
    
  end
  
  describe "without a login" do
    
    it "should not load the dashboard" do
      get :show
      response.should redirect_to(signin_url)
    end
    
  end

end
