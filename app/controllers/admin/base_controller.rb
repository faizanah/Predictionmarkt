class Admin::BaseController < ApplicationController
  prepend_view_path('app/views/admin/')

  before_action :authenticate_admin_user!
  before_action :require_superadmin
end
