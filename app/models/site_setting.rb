class SiteSetting < ActiveRecord::Base
  liquid_methods :name, :url
end
