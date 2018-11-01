module AdminHelper
  # TODO: test
  def admin_only(&block)
    return if @rendering_an_error
    return unless current_admin_user
    content = capture(&block)
    concat(content_tag(:div, content, class: 'admin-only-wrapper'))
    nil
  end
end
