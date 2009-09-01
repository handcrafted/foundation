require File.dirname(__FILE__) + '/../spec_helper'

describe ReferralsController do
  before(:each) do
    @site = site_settings(:site)
  end
  
  describe "with referrals disabled" do
    before(:each) do
      @site.referrals = false
      @site.save
    end
    
    it "should return a 404" do
      get :new
      response.status.should == "404 Not Found"
    end
    
  end

  describe "with referrals enabled" do
    
    before(:each) do
      @site.referrals = true
      @site.save
    end
    
    it "should require a login for GET new" do
      get :new
      response.should be_redirect
    end
    
    describe "when logged in" do
      
      before(:each) do
        unset_session
        set_session_for(Factory(:valid_user))
      end

      it "should GET new" do
        get :new
        response.should be_success
      end

      it "sends emails when new emails are given" do
        post :create, :referral => {:email_list => "joe@test.com\r\nbob@test.com", :email_text => "This is some sample text"}
        Referral.find_by_email_address("joe@test.com").should_not be_blank
      end
    end
    
  end
  
  
end