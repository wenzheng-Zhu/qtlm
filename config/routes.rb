Rails.application.routes.draw do
  
  get 'home/index'
  #post 'callback' => 'welcome#make'
  post 'callback' => 'welcome#shixian'
  # post 'wx' => 'welcome#huiyuanka'
   get '/foo' => 'welcome#bar'

   get '/zheng' => 'welcome#zheng'
  root 'home#index'
end
