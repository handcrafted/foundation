namespace :vlad do
  
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad do
    rails_env = rails_env || "production"
    local_user = ENV['USER'] || ENV['USERNAME']
    notify_command = "rake hoptoad:deploy TO=#{rails_env} REVISION=#{revision} REPO=#{repository} USER=#{local_user}"
    puts "Notifying Hoptoad of Deploy (#{notify_command})"
    response = `#{notify_command}`
    puts "Hoptoad Notification Complete. #{response}"
  end
  
  task :cleanup => [:notify_hoptoad]
  
end