require "grape-swagger"

module ChartsApi
  class Base < Grape::API
    format :json
    prefix '/charts/'

    add_swagger_documentation(
      api_version: "v1",
      hide_documentation_path: true,
      hide_format: true
    )

    helpers do
      include TimeHelper

      def config
        @config ||= Rails.application.config_for(:api).with_indifferent_access.freeze
      end
    end
  end
end
