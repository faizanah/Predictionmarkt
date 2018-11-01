module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_current_authenticated_user
  end

  def require_superadmin
    current_admin_user.try(:superadmin?)
  end

  def after_sign_in_path_for(resource)
    resource.is_a?(AdminUser) ? admin_markets_path : root_path
  end

  private

    def set_current_authenticated_user
      Current.user = current_user
    end
end
