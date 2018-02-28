Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#index"

  resources :products,   only: [:index, :show]

  resources :categories, only: [:index, :show]


  ### マイ・オークション ###
  namespace :myauction do

    ### 共通ページ ###
    root to: "main#index"
    resources :bids,       only: [:index, :new, :create, :show]
    resources :watches,    only: [:index, :create, :destroy]
    resources :follows,    only: [:index, :create, :destroy]
    resources :blacklists, only: [:index, :create, :destroy]
    resources :searches,   only: [:index, :new, :create, :update, :destroy]

    resource  :user,       only: [:edit, :update]

    ### 出品関係 ###
    resources :categories, only: [:index, :new, :create, :edit, :update]
    resources :products,   only: [:index, :new, :create, :edit, :update, :destroy] do
      # collection do
      #   post  'confirm'
      #   post  'prompt'
      # end

      member do
        patch 'cancel'
      end
    end

    resources :templates,  only: [:index, :new, :create, :edit, :update, :destroy]
    resources :importlog,  only: [:index,]
    resources :shipping,   only: [:index, :new, :create]

    resources :csv,   only: [:new, :create] do
      collection do
        post 'confirm'
        get  'progress'
      end
    end

    resources :trades, only: [:index, :create, :destroy]
    resources :stars,  only: [:edit, :update]

  end
end
