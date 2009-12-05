class Notifier < Mailer

  def password_reset_instructions(user)
    setup_template('password_reset', user.email) do |options|
      options['user'] = user
    end
  end

end
