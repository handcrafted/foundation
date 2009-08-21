require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
  
  it "should create a new email row when sending an email" do
    user = Factory(:valid_user)
    site = site_settings(:site)
    SiteSetting.should_receive(:find).and_return(site)
    site.should_receive(:admin_email).twice.and_return("admin@gethandcrafted.com")
    EmailTemplate.should_receive(:find_by_name).and_return(Factory(:email_template))
    mail = UserMailer.deliver_welcome_email(user)
  end
  
end