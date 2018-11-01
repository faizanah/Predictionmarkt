require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_storage/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Predictionmarkt
  class Application < Rails::Application
    config.generators do |g|
      g.scaffold_stylesheet false
      g.assets false
      g.helper false
      g.stylesheets false
      g.jbuilder false
    end

    config.assets.quiet = false
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.active_job.queue_adapter = :resque

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Need to set early because it's used in the initializers
    config.filter_parameters += %i[password token address key email] unless Rails.env.test?
    config.filter_parameters.uniq!

    config.autoload_paths += %W[#{config.root}/app/forms #{config.root}/app/inputs]
    config.autoload_paths += %W[#{config.root}/app/currencies #{config.root}/app/robots]
    config.autoload_paths += %W[#{config.root}/app/trading]
    config.autoload_paths += %W[#{config.root}/spec/support/external]

    # Grape
    config.paths.add File.join('app', 'apis'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'apis', '*')]

    # lib reload
    config.eager_load_paths += ["#{Rails.root}/lib}"]
  end
end
