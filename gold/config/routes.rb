ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resources :users
  map.resources :pages, :controller => 'pages', :only => [:show]
  
  map.root :controller => "pages", :action => "show", :id => "home"
end
