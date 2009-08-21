require File.dirname(__FILE__) + '/../spec_helper'
require 'pp'

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
    
    it "should GET new" do
      get :new
      response.should be_success
    end
    
    it "should process emails on POST create" do
      ReferralMailer.stub!(:deliver_admin_confirmation)
      Profile.stub!(:send_referral_emails)
      ReferralMailer.stub!(:deliver_confirmation)
      lambda do
        post :create, :referral => {:email_text => "Testing", :friends_email => "Tom@test.com\r\nBob@test.com", :first_name => "Joe", :last_name => "Schmo", :email => "Joe@test.com"}
      end.should change(Profile, :count).by(3)
    end
    
  end
  
  
end