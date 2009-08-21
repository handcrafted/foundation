require File.dirname(__FILE__) + '/../spec_helper'

describe InvitesController do

  describe "GET 'new'" do
    it "should be successful" do
      Invite.should_receive(:new)
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "should be successful" do
      lambda {
        post :create, :invite => {:email => "tom@test.com"}
      }.should change(Invite, :count)
      response.should redirect_to("/")
    end
    
    it "should render new invite action again when create failed" do
      invite = mock_model(Invite)
      Invite.should_receive(:create).and_return(invite)
      invite.should_receive(:errors).and_return([:email])
      post :create, :invite => {:email => "tom@test.com"}
      response.should render_template('new')
    end
    
  end
end
