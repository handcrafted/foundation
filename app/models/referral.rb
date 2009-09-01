class Referral < ActiveRecord::Base
  attr_accessor :email_list
  
  #Associations
  belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
  
  #Validations
  validates_format_of :email_address, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email_address, :on => :create, :message => "has already been invited to the site"
  validates_presence_of :email_text
  validate :email_address_isnt_a_user
  
  #Callbacks
  after_create :send_referral_emails
  
  
  private
  
    def send_referral_emails
      ReferralMailer.send_later(:deliver_referral, email_address, email_text)
      ReferralMailer.send_later(:deliver_confirmation, referrer.email, email_text) if referrer.email
    end
  
    def email_address_isnt_a_user
      errors.add("email_address", "has already signed up for the site") if User.find_by_email(email_address)
    end
  
end
