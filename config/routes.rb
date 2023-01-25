Rails.application.routes.draw do
    
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'login' => "sessions#create"
  delete '/logout/all' => "sessions#destroy"
  resources :users  
  resources :products
  post 'deposit' => "users#deposit"
  post 'reset' => "users#reset"
  post 'buy' => "products#buy"
  
end
