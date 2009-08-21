namespace :vlad do

  desc 'Stop the delayed job daemon'
  remote_task :stop_dj, :roles => :job do
    run "cd #{current_path} && ./script/worker stop -- production"
  end
  
  desc 'Start the delayed job daemon'
  remote_task :start_dj, :roles => :job do
    run "cd #{current_path} && ./script/worker start -- production"
  end

  task :start_app => [:stop_dj]
end