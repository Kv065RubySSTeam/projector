Rails.application.routes.draw do
  root "boards#index"
  resources :boards do
    resources :columns
  end
  devise_for :users, controllers: { registrations: 'registrations' },
  path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
  resource :user, only: [:show]
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
