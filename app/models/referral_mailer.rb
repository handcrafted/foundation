class ReferralMailer < Mailer

  def referral(profile, body)
    setup_template('referral', profile.email) do |options|
      options['note'] = body
    end
  end

  def confirmation(profile)
    setup_template('confirmation', profile.email)
  end

  def admin_confirmation(profile, referrals)
    setup_template('admin_confirmation', SiteSetting.first.admin_email) do |options|
      options['referrer'] = profile
      options['referrals'] = referrals
    end
  end

end
