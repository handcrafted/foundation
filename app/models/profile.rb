class Profile < ActiveRecord::Base
  liquid_methods :email
  
  belongs_to :user
  
  has_attached_file :avatar, :styles => {:thumb => "16x16>", :small => "48x48>", :large => "100x100>", :xlarge => "150x150>"}, :default_url => "/images/foundation/default_:style_avatar.png"
  
  def fullname
    return nil unless first_name && last_name
    "#{first_name} #{last_name}"
  end
  
  # def add_referrals(friends_list, email_text)
  #   emails = Profile.parse_friends_email(friends_list)
  #   referrals = emails.collect do |email|
  #     #Profile.find_or_create_by_email(:email => email, :referral => self)
  #   end
  #   Profile.send_referral_emails(self, referrals, email_text)
  #   referrals
  # end
  # 
  # def self.parse_friends_email(email_list = "")
  #   if email_list.include?("\r\n")
  #     emails = email_list.split(/\r\n/)
  #   else
  #     emails = email_list.split(/,/)
  #   end
  #   emails
  # end
  # 
  # def self.send_referral_emails(sender, referrals, text)
  #   referrals.each do |profile|
  #     ReferralMailer.send_later(:deliver_referral, profile, text)
  #   end
  #   ReferralMailer.send_later(:deliver_confirmation, sender)
  #   ReferralMailer.send_later(:deliver_admin_confirmation, sender, referrals)
  # end
  
end
