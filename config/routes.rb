Rails.application.routes.draw do
  root "boards#index"
  resources :boards
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }
  resource :user, only: [:show] do
    delete :delete_avatar
  end
end
