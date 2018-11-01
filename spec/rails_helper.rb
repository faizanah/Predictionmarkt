require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'webmock/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/email/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/*/shared/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

# TODO: duplicated in the initializers
Capybara.register_driver :chrome do |app|
  args = %w[headless disable-gpu --window-size=1280,1280]
  Capybara::Selenium::Driver.new app, browser: :chrome,
                                      options: Selenium::WebDriver::Chrome::Options.new(args: args)
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end
Capybara::Screenshot.webkit_options = { width: 1280, height: 800 }
Capybara.raise_server_errors = true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.include ActiveJob::TestHelper

  config.render_views

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  # config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
