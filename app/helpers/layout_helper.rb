module LayoutHelper
  # rubocop:disable Metrics/MethodLength
  def header_links
    if admin_space?
      { 'Markets'        => admin_markets_path,
        'Resque'         => '/admin/resque/overview' }
    elsif current_user
      { 'Markets'        => markets_path,
        'Orders'         => my_trading_orders_path,
        'Shares'         => my_shares_path,
        'Funds'          => my_funds_path }
    else
      { 'Markets'        => markets_path,
        'Blog'           => blog_path,
        'How it Works'   => how_path }
    end
  end

  def header_menu_items
    items = [current_user.email,
             link_to('Referrals', my_referrals_path),
             link_to('Sign Out', destroy_user_session_path, method: :delete)]
    items << link_to('Admin Sign Out', destroy_admin_user_session_path, method: :delete) if current_admin_user
    items
  end

  def session_menu_items
    [link_to('Sign In', new_user_session_path, class: 'session-menu__link'),
     link_to('Sign Up', new_user_registration_path, class: 'session-menu__link')]
  end

  def page_headline(title, args = {})
    headline = content_tag(:h1, title, class: 'page-headline')
    @page_title ||= title
    args[:no_wrapper] ? headline : content_tag('div', headline, class: 'page-headline-wrapper')
  end
end
