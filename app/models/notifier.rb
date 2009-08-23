class Notifier < ActionMailer::Base

  default_url_options[:host] = "authlogic_example.binarylogic.com"  

  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"  
    from          "Binary Logic Notifier "  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end  

end
