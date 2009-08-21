require File.join(File.dirname(__FILE__), "lib", "more_actions")

config.to_prepare do
  ApplicationController.helper(MoreActionsHelper)
end

ActionController::Base.class_eval do
  include MoreActions
end