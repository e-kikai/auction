Rails.application.routes.draw do
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  # devise_for :users
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    sessions:      'users/sessions',
  }

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#index"
  get "rss" => "main#rss", defaults: { format: :rss }
  get "pops/:lank" => "main#pops_lank"
  get "pops"       => "main#pops"

  resources :products,   only: [:index, :show] do
    member do
      get  'bids'
      # get  'nitamono'
      get 'process_vector'
    end

    collection do
      get 'ads'
    end
  end

  get "searches/:search_id" => "products#index"
  get "news_day/:news_day"  => "products#index"
  get "news(/:news_week)"   => "products#index", defaults: { news_week: Time.now }

  # resources :searches,   only: [:show]

  # resources :categories, only: [:index, :show]
  resources :companies,  only: [:show]
  resources :helps,      only: [:index, :show]
  resources :infos,      only: [:index, :show]

  resources :detail_logs,  only: [:index, :create]
  resources :search_logs,  only: [:create]
  resources :toppage_logs, only: [:create]

  resources :watches,      only: [:index] do
    collection do
      post "toggle"
    end
  end

  ### マイ・オークション ###
  namespace :myauction do

    ### 共通ページ ###
    root to: "main#index"
    resources :bids,       only: [:index, :new, :create, :show]
    resources :watches,    only: [:index, :create, :destroy] do
      collection do
        post "toggle"
      end
    end

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

    resources :answers, only: [:index, :create]
    get "answers/:product_id/:owner_id" => "answers#show"

    resources :contacts, only: [:index, :show, :create]

    resources :stars,  only: [:edit, :update]
    resources :helps,  only: [:index, :show]
    resources :infos,  only: [:index, :show]

    resources :total,  only: [:index] do
      collection do
        get 'products'
      end
    end

    resources :detail_logs,  only: [:index]

    resources :requests, only: [:index, :new, :create] do
      collection do
        get 'fin'
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
        get 'image'
        patch 'all_process_vector'
      end
    end

    resources :bids,        only: [:index]
    resources :detail_logs, only: [:index] do
      collection do
        get 'monthly'
        get "search"
      end
    end
    resources :search_logs,  only: [:index]
    resources :toppage_logs, only: [:index]
    resources :watches,      only: [:index]
    resources :searches,     only: [:index]
    resources :alerts,       only: [:index]
    resources :follows,      only: [:index]
    resources :trades,       only: [:index] do
      # collection do
      #   get "remake_owner"
      # end
    end
    get "trades/:product_id/:owner_id" => "trades#show"

    resources :total, only: [:index] do
      collection do
        get 'products'
        get 'products_monthly'
        get 'formula'
        get 'categories'
        get 'nitamono'
        get 'osusume'
        get 'uwatch'
      end
    end

    resources :scheduling, only: [:index] do
      collection do
        post 'product_scheduling'
        post 'alert_scheduling'
        post 'watch_scheduling'
        post 'twitter_new_product'
        post 'twitter_toppage'
        post 'twitter_news_week'
        post 'flyer_mail'
        post 'news_mail'
        post 'news_test'
      end
    end

    unless Rails.env.production?
      resources :playground, only: [:index] do
        collection do
          get 'search_01'
          get 'vector_maker'
          get 'vector_maker_solo'
          get 'vbpr_list'
          get 'bpr_list_02'
          get 'bpr_now_products'

          get 'vbpr_test'
          get 'vbpr_view'
          get 'vbpr_top'
        end

        member do
          get 'vbpr_detail'
        end
      end

      resources :playground_02, only: [:index] do
        collection do
          get 'search_02'
          get 'all_process_vector'
          get 'process_vector'
          get "csv"
          get "vectors_csv"
          get 'all_process_feature'
          get 'process_feature'
          get 'feature_test'
          get 'feature_csv'
          get 'feature_csv_test'
          get 'feature_csv_json'
          get 'plot_json'
          get 'vector_search_json'
          get 'feature_pair_test'
        end
      end
    end

    resources :data do
      collection do
        get  'vbpr'
        get  'top_url_by_category'
        get  'vectors'
        post 'vectors_import'
      end
    end

    resources :abtests,    only: [:index]
    resources :requests,   only: [:index]
    resources :blacklists, only: [:index]
  end
end
