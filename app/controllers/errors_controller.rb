class ErrorsController < ApplicationController
  before_action :set_error
  skip_before_action :authenticate_user!

  def render_error
    render 'error'
  end

  def current_user
    nil
  end

  def set_error
    @rendering_an_error = true
    @error_code = request.env['HTTP_ERROR_CODE']
    @page_title = t("errors.error_#{@error_code}.title")
    @page_description = t("errors.error_#{@error_code}.description")
  end
end
