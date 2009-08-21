namespace :vlad do
  
  desc "Update the crontab file"
  remote_task :update_crontab, :roles => :job do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end

  task :cleanup => [:update_crontab]
  
end