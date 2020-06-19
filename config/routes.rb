Rails.application.routes.draw do
  root "boards#index"
  concern :likable do
    namespace :cards do
      resource :likes, only: [:create, :destroy]
    end
    namespace :comments do
      resource :likes, only: [:create, :destroy]
    end
  end

  resources :boards do
    resources :columns, except: [:index, :show, :edit] do
      resources :cards, except: [:index, :show], concerns: :likable do
        member do
          put :update_position
          post :add_assignee
          delete :remove_assignee
        end
        resources :tags, only: [:create, :destroy]
        resources :comments, except: [:show], concerns: :likable
      end
    end

    member do
      get 'export'
      get 'members'
    end
  end

  resources :cards, only: [:index]
  resources :notifications, only: [:index]

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
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

end
