ActionController::Routing::Routes.draw do |map|
  # Home
  map.with_options(:controller => 'home') do |home|
    home.home '', :action => 'index'
    home.home_search 'search_stuff', :action => 'search'
  end
  
  # Contact
  map.with_options(:controller => 'contact') do |contact|
    contact.contact 'contact', :action => 'index'
  end
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
