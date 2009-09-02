require File.dirname(__FILE__) + '/../spec_helper'

describe Profile do
  fixtures :users
  
  # before do
  #   template = Factory(:email_template)
  #   EmailTemplate.stub!(:find_by_name).and_return(template)
  # end
  
  describe "validations and associations " do
    
    before(:each) do
      @profile = Profile.new
    end
    
    it "belongs to a user" do
      @profile.should belong_to(:user)
    end
    
  end
  
  # describe "handles referrals properly" do
  # 
  #   it "returns the referral properly" do
  #     referrer = create_profile
  #     referred = create_profile(:email => "josh@test.com", :first_name => "Josh", :referral => referrer)
  #     referred.referral.should == referrer
  #   end
  #   
  # end
  # 
  # it "should parse the email list" do
  #   list = Profile.parse_friends_email("Tom@test.com\r\nBob@test.com")
  #   list.should == ["Tom@test.com", "Bob@test.com"]
  # end
  # 
  # describe "processes email referral lists" do
  #   before(:each) do
  #     @profile = create_profile
  #     Profile.stub!(:send_referral_emails)
  #     ReferralMailer.stub!(:deliver_confirmation)
  #     ReferralMailer.stub!(:deliver_admin_confirmation)
  #   end
  #   
  #   it "should take a profile and add the referrals from the email list" do
  #     lambda do
  #       @profile.add_referrals("Tom@test.com\r\nBob@test.com", "Test")
  #     end.should change(Profile, :count).by(2)
  #   end
  #   
  #   it "should save the referral email address" do
  #     referrals = @profile.add_referrals("Tom@test.com", "Test")
  #     referrals.first.email.should == "Tom@test.com"
  #   end
  #   
  # end
  # 
  # describe "processes email lists and sends email" do
  #   before(:each) do
  #     @profile = create_profile
  #   end
  #   
  #   it "should email referrals" do
  #     referral1 = Factory(:profile, :referral => @profile)
  #     ReferralMailer.should_receive(:send_later).with(:deliver_referral, referral1, "Test")
  #     ReferralMailer.should_receive(:send_later).with(:deliver_confirmation, @profile)
  #     ReferralMailer.should_receive(:send_later).with(:deliver_admin_confirmation, @profile, [referral1])
  #     Profile.send_referral_emails(@profile, [referral1], "Test")
  #   end
  #   
  # end
  
  describe "handles profile data" do
    it "should return nil if first name and last name are not set" do
      profile = create_profile(:first_name => nil, :last_name => nil)
      profile.fullname.should be_nil
    end
    
    it "should return a string when calling fullname and first/last name are set" do
      profile = create_profile
      profile.fullname.should == "Joe Sixpack"
    end
  end
  
  protected
  
  def create_profile(options = {})  
    Factory(:profile, options)
  end
  
end
