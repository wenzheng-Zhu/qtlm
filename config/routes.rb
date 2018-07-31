Rails.application.routes.draw do
  
  get 'home/index'
  #post 'callback' => 'welcome#make'
  post '/callback' => 'welcome#shixian'
  # get '/foo' => 'welcome#bar'
  root 'home#index'
end
