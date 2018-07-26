Rails.application.routes.draw do
  
  get 'home/index'
  #post 'callback' => 'welcome#make'
  post 'callback' =>'welcome#fuck'

  root 'home#index'
end
