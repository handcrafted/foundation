class Referral < ActiveRecord::Base
  attr_accessor :email_list, :email_text
  
  belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
  
end
