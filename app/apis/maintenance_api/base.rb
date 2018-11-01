require "grape-swagger"

module MaintenanceApi
  class Base < Grape::API

    include AuthenticateMaintenanceRequest
    format :json
    prefix '/maintenance/'

    before do
      authenticate!
    end

    add_swagger_documentation(
      api_version: "v1",
      hide_documentation_path: true,
      hide_format: true
    )

    helpers do
      def config
        @config ||= Rails.application.config_for(:api).with_indifferent_access.freeze
      end
    end
  end
end
