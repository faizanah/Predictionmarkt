require 'resque/server'
require 'resque/scheduler'
require 'resque/scheduler/server'

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root to: 'markets#index'
  # get 'theme', to: 'welcome#theme'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks',
                                    registrations: 'users/registrations',
                                    sessions: 'users/sessions' }
  devise_for :admin_users, path: 'admin/profile', format: false, skip: [:registrations]

  resources :markets do
    member do
      get 'cover/*filename' => 'markets#cover', as: 'cover', format: false
    end
    collection do
      get 'watchlist/:list' => 'markets#watchlist', as: 'watchlist'
    end
    resources :market_outcomes, shallow: true
    resources :trading_sets, path: 'sets', shallow: true
  end

  resources :market_outcomes, path: 'outcomes' do
    resources :trading_orders, path: 'orders', shallow: true do
      collection do
        put 'preview'
        get 'help'
      end
    end
  end

  namespace :my do
    resources :funds do
      collection do
        match 'withdraw/:currency' => 'funds#withdraw', as: 'withdraw', via: %w[get post]
        get 'statement/:currency' => 'funds#statement', as: 'statement'
      end
    end

    resources :shares
    resources :trading_orders, path: 'orders'
    resources :trading_sets, path: 'sets'
    resources :referrals
  end

  get 'browse/:category_id/*name' => 'markets#index', as: 'market_category'
  get 'market/:id/:title' => 'markets#show', as: 'titled_market'

  get 'blog' => 'blog#index', as: 'blog'
  get 'blog/:id/*title' => 'blog#show', as: 'blog_post'
  post'blog/subscribe' => 'blog#subscribe', as: 'blog_subscribe'

  mount ApplicationApi, at: '/api/'

  admin_constraint = lambda do |request|
    admin = request.env['warden'].user(:admin_user)
    admin.is_a?(AdminUser) && admin.superadmin?
  end

  constraints admin_constraint do
    mount Resque::Server.new, at: '/admin/resque'
    namespace :admin do
      get 'browse/:category_id/*name' => 'markets#index', as: 'market_category'
      resources :markets do
        resources :market_outcomes
      end
    end
  end

  %w[about how terms fees security referral].each do |page|
    get page => "pages##{page}", as: page
  end
  get 'bounty' => redirect('/referral')
end
