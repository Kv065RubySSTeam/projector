Rails.application.routes.draw do
  root "boards#index"
  resources :boards
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
                    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
  resources :users, only: [:show]
end
