Rails.application.routes.draw do
  root "boards#index"

  resources :boards do
    post 'memberships/' => 'memberships#create', as: :memberships_create
    put 'members/:user_id/admin' => 'memberships#admin', as: :add_admin_rights
  end

  devise_for :users, controllers: { registrations: 'registrations' },
  path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
  resource :user, only: [:show]
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
