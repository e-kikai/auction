Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#index"

  resources :products,   only: [:index, :show]
  resources :categories, only: [:index, :show]
  resources :bids,       only: [:create] do
    member do
      post :conf
      post :prompt_conf
      post :prompt_create
    end
  end


  ### マイ・オークション ###
  namespace :myauction do

    ### 共通ページ ###
    root to: "main#index"
    resources :mylists,    only: [:index, :create, :destroy]
    resources :follows,    only: [:index, :create, :destroy]
    resources :blacklists, only: [:index, :create, :destroy]

    resources :users,      only: [:index, :create, :destroy]

    ### 出品関係 ###
    resources :categories, only: [:index]
    resources :products,   only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get   :end
      end
    end
  end
end
