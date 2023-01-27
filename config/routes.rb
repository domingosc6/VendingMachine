Rails.application.routes.draw do
    
  post 'login', to: 'sessions#create'
  delete '/logout/all', to: 'sessions#destroy'
  put 'user', to: 'users#update'
  resources :users, only: [:create, :index, :destroy]
  resources :products
  post 'deposit', to: 'users#deposit'
  post 'reset', to: 'users#reset'
  post 'buy', to: 'products#buy'
  get 'profile', to: 'users#profile'
  
end
