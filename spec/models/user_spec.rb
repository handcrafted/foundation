require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  
  it "creates a valid user" do
    Factory.create(:valid_user)
  end
  
  it "creates a valid user with an empty login string" do
    Factory.create(:valid_user, :login => "")
  end
  
  it "doesn't create an invalid user" do
    Factory.build(:invalid_user).should be_invalid
  end
  
  describe "with password generation" do
    
    it "saves the generated password for a user" do
      pending
    end
    
    it "marks a password for change" do
      pending
    end
    
  end
  
  describe "with profile support" do
    
    before(:each) do
      @user = Factory.create(:valid_user, :email => 'joe.sixpack@gmail.com')
    end
    
    it "shows the email as the proper display name when the profile is not set" do
      @user.display_name.should == "joe.sixpack@gmail.com"
    end
    
    it "shows the first and last name as the proper display name when the profile is set" do
      @user.profile = Factory.create(:profile)
      @user.display_name.should == "Joe Sixpack"
    end
    
  end
  
  describe "with admin" do
    before(:each) do
      User.delete_all
      User.count.should == 0
    end
    
    
    it "upgrades the first user to an admin" do
      user = Factory.create(:valid_user)
      user.should be_admin
    end
  
    it "doesn't auto-upgrade subsquent users to admin" do
      user = Factory.create(:valid_user)
      user2 = Factory.create(:valid_user, :email => "joe.plumber@gmail.com")
      user2.should_not be_admin
    end
    
  end
  
end