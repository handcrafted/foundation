# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bootstrap-os_session',
  :secret      => '00d8501b989a7145435b19d7dd142dd2c38fa12569dfe388706be66f276e5129d9cbbcafea9eaf50c786950f8124e859562111436199d20ca9471cd5ba24666b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
