# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W(#{RAILS_ROOT}/app/jobs)

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  # config.gem "tinder", :lib => false
  config.gem 'authlogic'
  config.gem 'will_paginate', :lib => 'will_paginate', :source => 'http://gemcutter.org'
  config.gem 'paperclip', :lib     => 'paperclip', :source  => 'http://gemcutter.org', :version => '>= 2.2.9'
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org', :version => '>= 0.3.7'
  config.gem 'friendly_id'
  config.gem 'newrelic_rpm'
  config.gem 'liquid'
  config.gem 'haml', :version => '>= 2.2.0'
  config.gem 'compass', :source => 'http://gemcutter.org', :version => '>= 0.8.5'
  config.gem 'grid-coordinates', :lib => 'compass', :source => 'gemcutter.org', :version => '>= 1.0.3'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :invite_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
