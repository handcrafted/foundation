class ReferralMailer < Mailer

  def referral(email, body)
    setup_template('referral', email) do |options|
      options['note'] = body
    end
  end

  def confirmation(email)
    setup_template('confirmation', email)
  end

  # def admin_confirmation(profile, email_address)
  #   setup_template('admin_confirmation', SiteSetting.first.admin_email) do |options|
  #     options['referrer'] = profile
  #     options['referrals'] = referrals
  #   end
  # end

end
