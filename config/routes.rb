Rails.application.routes.draw do
  
  post 'callback' => 'welcome#make'

  root 'welcome#make'
end
