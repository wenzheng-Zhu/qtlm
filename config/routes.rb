Rails.application.routes.draw do
  
  get 'home/index'
  post 'callback' => 'welcome#make'

  root 'home#index'
end
