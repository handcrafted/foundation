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
    
    it "sends emails when new emails are given" do
      pending
    end
    
  end
  
  
end