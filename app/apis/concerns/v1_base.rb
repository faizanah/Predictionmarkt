module V1Base
  extend ActiveSupport::Concern
  CONFIG = Rails.application.config_for(:api).with_indifferent_access.freeze

  HEADERS_DOCS = {
    Authorization: {
      description: "User Authorization Token",
      required: true
    }
  }

  RESPONSE_CODE = {
    success: 200,
    bad_request: 400,
    unauthorized: 401,
    forbidden: 403,
    not_found: 404,
    unprocessable_entity: 422,
    internal_server_error: 500,
    common_error: 1001
  }

  PER_PAGE = 20

  included do
    format :json
    default_format :json
    prefix :api

    version 'v1', using: :header, vendor: 'PredictionMarkt'

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_error(RESPONSE_CODE[:not_found], I18n.t("errors.#{e.model.to_s.downcase}.not_found"))
    end

    rescue_from ApiException do |e|
      render_error(e.http_status, e.error.message, e.error.debug_info)
    end

    helpers do
      def logger
        Rails.logger
      end

      def render_error(code, message, debug_info = '')
        error!({meta: {code: code, message: message, debug_info: debug_info}}, code)
      end

      def render_success(json, extra_meta = {})
        {data: json, meta: {code: RESPONSE_CODE[:success], message: "success"}.merge(extra_meta)}
      end

      def pagination_dict(object)
        {
          current_page: object.current_page,
          next_page: object.next_page || -1,
          prev_page: object.prev_page || -1,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end
