module AuthHelper
  def oauth_link(title, url, icon_name)
    icon_element = icon('fab', icon_name, class: 'sb-auth__icon')
    link_to icon_element, url, title: "Sign in with #{title}",
                               class: 'sb-auth__link',
                               rel: 'nofollow',
                               data: { turbolinks: false }
  end
end
