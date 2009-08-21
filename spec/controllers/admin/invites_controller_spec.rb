require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::InvitesController do
  fixtures :users
  
  before(:each) do
    unset_session
    set_session_for(Factory(:admin_user))
  end
  
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      invite = mock_model(Invite)
      Invite.should_receive(:find).with("1").and_return(invite)
      invite.should_receive(:destroy)
      get 'destroy', :id => 1
      response.should redirect_to(admin_invites_url)
    end
  end

  describe "GET 'approve'" do
    it "should be successful" do
      invite = mock_model(Invite)
      Invite.should_receive(:find).and_return(invite)
      invite.should_receive(:approve!)
      invite.should_receive(:save)
      get 'approve', :id => 1
      response.should redirect_to(admin_invites_url)
    end
  end
  
  describe "POST 'reset'" do
    it "resets all user invite levels" do
      User.should_receive(:update_all).with("invites = 5")
      post :reset, :invite => {:number => 5}
      flash[:notice].should == flash[:notice] = "All user invites have been reset to 5"
      response.should redirect_to(admin_invites_url)
    end
  end
end
