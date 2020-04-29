Rails.application.routes.draw do
  resources :boards
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' } 
  resources :users, only: [:show]
end
