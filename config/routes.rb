Rails.application.routes.draw do
  get 'users/index'

  resources :boards do
    resources :memberships, only: %i[create]
    put 'members/:user_id/admin' => 'memberships#admin'
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
end
