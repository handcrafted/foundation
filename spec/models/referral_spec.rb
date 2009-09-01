require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Referral do
  
  it "creates a valid referral" do
    referral = Factory.create(:valid_referral)
    referral.should be_valid
  end
  
  it "doesn't create an invalid referral" do
    referral = Factory.build(:invalid_referral)
    referral.should be_invalid
  end
  
  it "sends a referral email when a new referral is created" do
    lambda do
      referral = Factory.create(:valid_referral)
    end.should change(Delayed::Job, :count)
  end
  
  it "should only send an email to an email address once" do
    referral1 = Factory.create(:valid_referral, :email_address => "valid_email@example.com")
    referral2 = Factory.build(:valid_referral, :email_address => "valid_email@example.com")
    referral1.should be_valid
    referral2.should be_invalid
  end
  
  it "doesn't create a new referral if the email matches a user's email" do
    user = Factory.create(:valid_user, :email => "joe@sixpack.com")
    referral = Factory.build(:valid_referral, :email_address => "joe@sixpack.com")
    referral.should be_invalid
  end
  
end
