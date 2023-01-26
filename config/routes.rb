Rails.application.routes.draw do
    
  post 'login' => 'sessions#create'
  delete '/logout/all' => 'sessions#destroy'
  resources :users, only: [:create, :index]
  resources :products
  post 'deposit' => 'users#deposit'
  post 'reset' => 'users#reset'
  post 'buy' => 'products#buy'
  get 'profile' => 'users#profile'
  
end
