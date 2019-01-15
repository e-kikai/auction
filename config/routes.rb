Rails.application.routes.draw do
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  # devise_for :users
  devise_for :users, controllers: { registrations: 'users/registrations', :confirmations => 'users/confirmations' }

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#index"

  resources :products,   only: [:index, :show] do
    member do
      get 'bids'
    end
  end

  get "searches/:search_id" => "products#index"
  # get "news"                => "products#index"
  # resources :searches,   only: [:show]

  resources :categories, only: [:index, :show]
  resources :companies,  only: [:show]
  resources :companies,  only: [:show]
  resources :companies,  only: [:show]
  resources :helps,      only: [:index, :show]
  resources :infos,      only: [:index, :show]

  resources :detail_logs,  only: [:create]
  resources :search_logs,  only: [:create]
  resources :toppage_logs, only: [:create]

  ### マイ・オークション ###
  namespace :myauction do

    ### 共通ページ ###
    root to: "main#index"
    resources :bids,       only: [:index, :new, :create, :show]
    resources :watches,    only: [:index, :create, :destroy]
    resources :follows,    only: [:index, :create, :destroy]
    resources :blacklists, only: [:index, :create, :destroy]
    resources :searches,   only: [:index, :new, :create, :edit, :update, :destroy]
    resources :alerts,     only: [:index, :new, :create, :edit, :update, :destroy]

    resource  :user,       only: [:edit, :update]

    ### 出品関係 ###
    resources :categories, only: [:index, :new, :create, :edit, :update]
    resources :products,   only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get  'm2a'
      end

      member do
        patch 'cancel'
        get   'additional'
        patch 'additional_update'
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
    resources :helps,  only: [:index, :show]
    resources :infos,  only: [:index, :show]

    resources :total,  only: [:index] do
      collection do
        get 'products'
      end
    end
  end

  ### 管理者ページ ###
  namespace :system do
    root to: "main#index"

    resources :categories, only: [:index, :new, :create, :edit, :update]
    resources :users,      only: [:index, :new, :create, :edit, :update, :destroy] do
      member do
        post  'signin'
        get   'edit_password'
        patch 'update_password'
      end

      collection do
        get 'total'
      end
    end

    resources :helps,       only: [:index, :new, :create, :edit, :update, :destroy]
    resources :infos,       only: [:index, :new, :create, :edit, :update, :destroy]
    resources :products,    only: [:index, :destroy] do
      collection do
        get 'finished'
        get 'finished_month'
        get 'results'
      end
    end

    resources :bids,        only: [:index]
    resources :detail_logs, only: [:index]
    resources :search_logs, only: [:index]
    resources :watches,     only: [:index]
    resources :searches,    only: [:index]
    resources :alerts,      only: [:index]
    resources :follows,     only: [:index]

    resources :total,       only: [:index] do
      collection do
        get 'products'
        get 'formula'
      end
    end

    resources :scheduling, only: [:index] do
      collection do
        get 'product_scheduling'
        get 'alert_scheduling'
        get 'watch_scheduling'
        get 'twitter_new_product'
        get 'twitter_toppage'
        get 'flyer_mail'
      end
    end
  end
end
