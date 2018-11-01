class ApplicationController < ActionController::Base
  helper :all
  helper_method :admin_space?

  include Authentication
  include SetCurrentRequestDetails

  protect_from_forgery with: :exception
  before_action :set_raven_context

  def admin_space?
    self.class.parent == Admin
  end

  private

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
end
