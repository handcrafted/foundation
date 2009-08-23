class User < ActiveRecord::Base
  acts_as_authentic
  
  liquid_methods :display_name
  
  attr_protected :admin
  
  #Associations
  has_one :profile
  
  #Callbacks
  before_create :make_first_admin
  
  def self.invite_count
    User.sum(:invites)
  end

  def make_first_admin
    self.admin = true if first_user?
  end
  
  def first_user?
    User.count == 0
  end
  
  def display_name
    return profile.fullname if profile && profile.fullname
    email
  end
  
  def has_invites?
    invites > 0 || admin?
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end

end
