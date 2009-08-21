class UserMailer < Mailer

  def welcome_email(user)
    setup_template('welcome', user.email) do |options|
      options['user'] = user
    end
  end
  
end
