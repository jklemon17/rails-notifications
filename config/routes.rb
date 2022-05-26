Rails.application.routes.draw do
  require 'sidekiq/web'

  require 'sidekiq-scheduler/web'

  Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/apidocs' => 'api/v1/apidocs#index'
  get '/docs' => redirect("/api_html/dist/index.html?url=/apidocs")

  root 'api/v1/home#index_public'

  constraints subdomain: 'api' do
    # some namespace
  end

  namespace :api do
    scope module: 'v1' do
      get '/' => 'home#index_public'
    end
    namespace :v1 do
      post '/users/password_resets' => 'users#password_reset_create'
      patch '/users/password_resets' => 'users#password_reset_update'
      get '/users/top' => 'users#top_people'
      get '/users/available' => 'users#user_available'
      resources :users, only: [:index, :show, :update, :destroy]
      resources :sports, only: [:index, :show]
      resources :games, only: [:index, :show]
      resources :players, only: [:index, :show]
      get '/players/chart/:id' => 'players#get_chart'
      resources :player_games, only: [:index, :show]
      get '/player_games/price/:id' => 'player_games#get_price'
      get '/orders/privacy' => 'orders#change_privacy_for_current_market'
      get '/orders/stack' => 'orders#stack'
      resources :orders, only: [:index, :show, :create, :update]
      get '/orders/social/:id' => 'orders#social'
      resources :payouts, only: [:index, :show]
      resources :transactions, only: [:index, :show, :create]
      resources :friendships, only: [:index, :create, :update]
      resources :likes, only: [:index, :show, :create, :destroy]
      resources :comments, only: [:index, :show, :create, :update, :destroy]
    end
  end
  
  devise_for :users, defaults: { format: :json }, controllers: {
    registrations:  "users/registrations",
    confirmations:  "users/confirmations",
    sessions:       "users/sessions",
    passwords:      "users/passwords",
  }
end
