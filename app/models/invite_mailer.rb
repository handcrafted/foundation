class InviteMailer < Mailer
  
  def invite_notification(invite)
    setup_template('invitation', invite.email)
  end
end
