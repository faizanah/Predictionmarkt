require 'rails_helper'

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.include FormHelpers, type: :feature

  config.before(:example, type: :feature) do
    WebMock.disable_net_connect!(allow_localhost: true)
    Capybara.javascript_driver = :chrome
    Capybara.current_driver = :chrome
    Capybara.ignore_hidden_elements = true
    Capybara.default_max_wait_time = 10
    Capybara.raise_server_errors = true
    # Capybara.always_include_port = true
    Rails.application.routes.default_url_options = {
      host: "http://localhost:#{Capybara.current_session.server.port}",
      port: Capybara.current_session.server.port
    }
  end

  config.before(:suite) do
    Rails.application.load_tasks
    Rake::Task["assets:precompile"].invoke
  end
end
