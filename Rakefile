# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# Vlad stuff
begin
  require 'vlad'
  Vlad.load :app => :passenger, :scm => :git
rescue LoadError
  # do nothing
end

require(File.join(RAILS_ROOT, 'vendor', 'gems', 'jscruggs-metric_fu-1.1.4', 'lib', 'metric_fu'))