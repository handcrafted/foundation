require File.dirname(__FILE__) + '/../spec_helper'

describe Invite do
  fixtures :users
  
  it  do
    invite = Invite.new
    invite.should validate_presence_of(:email)
  end
  
  it do
    invite = Invite.new
    invite.should validate_uniqueness_of(:email)
  end
  
  it "should not add an invite for an existing user" do
    user = Factory(:valid_user)
    invite = Factory.build(:invite, :email => user.email)
    invite.should_not be_valid
    invite.should have(1).error_on(:email)
  end
  
  it "should belong to an inviter" do
    invite = Invite.new
    invite.should belong_to(:inviter)
  end
  
  it "should belong to a user" do
    invite = Invite.new
    invite.should belong_to(:user)
  end
  
  it "should use an invite" do
    invite = create_invite
    invite.should_not be_used
    invite.use!
    invite.should be_used
  end 
  
  it "adds the inviter and decrements the invite count" do
    user = Factory(:valid_user, :invites => 1)
    invite = Factory.build(:invite)
    invite.add_inviter(user)
    invite.save
    user.reload
    user.invites.should == 0
    invite.inviter.should == user
  end
  
  it "should not allow invites to be sent when you are out of them" do
    user = Factory(:valid_user, :invites => 0)
    
    lambda do
      invite = create_invite
    end.should_not change(user, :invites)
  end
  
  it "should mark an invite as sent" do
    InviteMailer.stub!(:deliver_invite_notification)
    
    ActiveRecord::Observer.with_observers(:invite_observer) do
      invite = create_invite
      invite.should be_sent
    end
  end
  
  it "should not mark an unapproved invite as sent" do
    ActiveRecord::Observer.with_observers(:invite_observer) do
      invite = create_invite(:inviter_id => nil)
      invite.should be_unsent
      invite.save
      invite.should be_unsent
    end
  end
  
  it "should send! an invite" do
    InviteMailer.stub!(:deliver_invite_notification)
    
    ActiveRecord::Observer.with_observers(:invite_observer) do
      invite = Invite.new(:email => 'quire@example.com')
      invite.save
      invite.should_not be_sent
      invite.sent_at.should be_nil
      invite.approve
      invite.reload
      invite.should be_sent
    end
  end
  
  protected
    def create_invite(options = {})
      Factory(:invite, options)
    end
  
end