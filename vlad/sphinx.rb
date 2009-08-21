namespace :vlad do
  
  desc 'Symlinks your custom directories'
  remote_task :symlink, :roles => :job do
    run "ln -s #{shared_path}/db/sphinx #{latest_release}/db/sphinx"
    run "ln -s #{shared_path}/config/production.sphinx.conf #{latest_release}/config"
  end
  
  desc 'Stop sphinx server'  
  remote_task :stop_sphinx, :roles => :job do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
  end

  desc 'Start sphinx server'  
  remote_task :start_sphinx, :roles => :job do
    run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
  end

  desc 'Restart sphinx server'
  task :restart_sphinx => ['vlad:stop_sphinx', 'vlad:start_sphinx']
  
  task :start_app => [:restart_sphinx]
end