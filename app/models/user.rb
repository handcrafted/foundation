class User < ActiveRecord::Base
  acts_as_authentic do
    login_field :email
    validate_login_field :false
  end
  
  has_friendly_id :login, :use_slug => true
  
  liquid_methods :display_name, :perishable_token
  
  attr_protected :admin
  
  #Validations
  validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :email
  validates_presence_of :login
  validates_length_of :email,    :within => 3..100
  
  #Associations
  has_one :profile
  
  #Callbacks
  before_validation_on_create :make_login
  before_create :make_first_admin
  after_create :create_profile
  
  #Nested Attribuets
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  def self.invite_count
    User.sum(:invites)
  end

  def make_first_admin
    self.admin = true if first_user?
  end
  
  # def create_profile
  #   profile.create
  # end
  
  def make_login
    self.login = self.email.split("@")[0] if self.login.blank? && !self.email.blank?
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
    Notifier.send_later(:deliver_password_reset_instructions, self)  
  end

end
