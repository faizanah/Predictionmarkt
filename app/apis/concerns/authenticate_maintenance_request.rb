module AuthenticateMaintenanceRequest
  extend ActiveSupport::Concern

  included do |base|
    helpers do
      def current_user
        return 'dev' if Rails.env.development? || Rails.env.test?
        return nil if request.headers['Authorization'].blank?
        return nil if Digest::SHA256.hexdigest(request.headers['Authorization'].split.last) != config[:maintenance_auth_hash]
        @current_user ||= 'maintanance-user'
      end

      def authenticate!
        raise error!({meta: {code: 401, message: 'not authenticated', debug_info: ''}}, 401) unless current_user
      end

      def authenticate_request!
        authenticate!
      end
    end
  end
end
