namespace :vlad do

  task :campfire do
    require 'tinder'
    campfire = Tinder::Campfire.new 'subdomain', :ssl => false
    campfire.login 'campfire@user.com', 'password'
    ROOM = campfire.find_room_by_name campfire_room    
  end

  task :pre_announce => [:campfire] do
    ROOM.paste "#{ENV['USER']} is preparing to deploy #{application}"
  end

  task :post_announce do
    ROOM.paste "#{ENV['USER']} finished deploying #{application}"
  end
  
  task :update => [:pre_announce]
  
  task :start_app => [:post_announce]

end