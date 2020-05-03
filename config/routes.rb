Rails.application.routes.draw do
  resources :boards
  resources :users, only: [:show]
  get 'users/index'
  post '/boards/:id/memberships/' => 'memberships#create', as: :memberships_create
  put '/boards/:id/members/:user_id/admin' => 'memberships#admin', as: :add_admin_rights
  
  resources :boards do
    # resources :memberships, only: %i[create]
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
end
