ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.resources :pages
  map.resources :invites, :referrals
  # APP MARKER - Place app specific routes below this line
  
  map.namespace :admin do |admin|
    admin.resource :dashboard, :controller => "dashboard"
    admin.resource :site_setting
    admin.resources :invites, :collection => {:manage => :post, :reset => :post}, :member => {:approve => :get}
    admin.resources :emails, :collection => {:manage => :post}
    admin.resources :users, :collection => {:manage => :post}
    admin.resources :profiles, :collection => {:manage => :post}
    # APP MARKER - Place app specific routes below this line
  end
  
  map.admin "/admin", :controller => "admin/dashboard", :action => "show"

  map.signup "/signup", :controller => "users", :action => "new"
  map.signout "/signout", :controller => "user_sessions", :action => "destroy"
  map.signin "/signin", :controller => "user_sessions", :action => "new"
  # APP MARKER - Place app specific routes below this line
  
  map.static_page "/:id", :controller => "pages", :action => "show"
  
  map.root :page
end
