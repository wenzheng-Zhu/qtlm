Rails.application.routes.draw do
  
  get 'home/index'
  #post 'callback' => 'welcome#make'
  post 'callback' =>'welcome#shixian'

  root 'home#index'
end
