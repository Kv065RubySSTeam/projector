Rails.application.routes.draw do
  root "boards#index"
  resources :boards do
    resources :columns, except: [:index, :show, :edit] do
      resources :cards, except: [:index, :show] do
        member do
          put :update_position
        end
        resources :tags, only: [:create, :destroy]
        resources :comments, except: [:show]
      end
    end

    member do
      get 'export'
    end
  end

  resources :cards, only: [:index]

  devise_for :users,
              controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' },
              path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' }

  resources :boards do
    resources :memberships, only: [:create] do
      put :admin, on: :member
    end
  end

  resource :user, only: [:show]
  resources :users, only: %i[index]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
