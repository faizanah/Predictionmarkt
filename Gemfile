source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

group :default, :rails do
  gem 'bootsnap', require: false
  gem 'coffee-rails', '~> 4.2'
  gem 'jbuilder', '~> 2.5'
  gem 'jquery-rails'
  gem 'mini_magick', require: false # favicon converter + active storage
  gem 'mysql2' # '~> 0.3.20'
  # TODO: fix this shit once released
  gem 'rails', git: 'https://github.com/rails/rails.git', tag: 'v5.2.0.rc1' # '~> 5.1.4'
  gem 'redis', '~> 4.0'
  gem 'sassc-rails' # 'sass-rails'
  gem 'slim-rails'
  gem 'sqlite3'
  gem 'turbolinks', '~> 5'
  gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
  gem 'uglifier', '>= 1.3.0'
  gem 'unicorn-rails'
  gem 'webpacker'
end

group :default, :debug do
  gem 'rbtrace', require: false
end

group :default, :misc do
  gem 'awesome_nested_set'
  gem 'awesome_print', '~> 1.8.0'
  gem 'betfair-ng'
  gem 'coinmarketcap'
  gem 'descriptive-statistics'
  gem 'highline'
  gem 'meta-tags'
  gem 'nokogiri'
  gem 'pinnaclesports', git: 'https://github.com/jedld/pinnaclesports.git'
  gem 'redcarpet'
  gem 'sentry-raven'
  gem 'sitemap_generator'
  gem 'sportradar-api'
  gem 'symmetric-encryption'
end

group :default, :forms do
  gem 'enum_help'
  gem 'simple_form'
end

group :default, :emails do
  gem 'roadie-rails'
end

group :default, :http do
  gem 'capybara'
  gem 'httparty'
  gem 'selenium-webdriver'
end

group :default, :security do
  gem 'idy'
  gem 'secure_headers'
end

group :default, :money do
  gem 'bitcoin-ruby'
  gem 'blockchain'
  gem 'eth'
  gem 'etherscan'
  gem 'money'
  gem 'money-open-exchange-rates'
end

group :default, :grape do
  gem 'grape'
  gem 'grape-entity'
  gem 'grape-swagger'
  gem 'grape_on_rails_routes'
end

group :default, :resque do
  gem 'active_scheduler'
  gem 'resque'
  gem 'resque-backtrace'
  gem 'resque-scheduler'
  gem 'resque-sentry'
end

group :default, :auth do
  gem 'devise'
  gem 'devise-i18n'
  gem 'omniauth-facebook'
  gem 'omniauth-google-oauth2'
  gem 'omniauth-twitter'
end

group :default, :icons do
  gem 'font-awesome-sass'
  # gem 'material_icons' disabled because no unicode support in the css. useless.
end

group :default, :ux do
  gem 'active_link_to'
  gem 'google_visualr'
  gem 'groupdate'
  gem 'kaminari'
  gem 'rails-bootstrap-tabs'
end

group :development do
  gem 'better_errors', '~> 2.4.0'
  gem 'binding_of_caller', '~> 0.7.3'
  gem 'brakeman', '~> 4.0.1', require: false
  gem 'fast_xs'
  gem 'favicon_maker'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2slim'
  gem 'letter_opener'
  gem 'listen'
  gem 'overcommit'
  gem 'pry-rails', '~> 0.3.6'
  gem 'rainbow'
  gem 'web-console' # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
end

group :development, :test do
  gem 'byebug' # , platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara-email'
  gem 'capybara-screenshot'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 3.7.1'
  gem 'simplecov', require: false
  gem 'sinatra'
  gem 'webmock'
  gem 'xray-rails', '~> 0.3.1'
end

group :deployment do
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules', require: false
  gem 'capistrano-rails', require: false
  gem 'unicorn', require: false, platform: :mri
end
