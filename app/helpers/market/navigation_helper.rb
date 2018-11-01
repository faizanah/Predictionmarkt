module Market::NavigationHelper
  def nav_menu_link_groups
    @nav_menu_link_groups ||= nav_categories_groups + [nav_bottom_links]
  end

  def nav_chips_link_groups
    @nav_chips_link_groups ||= nav_categories_groups
  end

  def nav_categories_groups
    @nav_categories_groups ||= @nav_categories.map do |top_level_category, children|
      links = []
      links << watch_list_links if top_level_category.name == 'Generated'
      children.each do |category|
        category.self_and_descendants.each { |cat| links << nav_category_link(cat) }
      end
      links.compact
    end
  end

  # TODO: test
  def watch_list_links
    return nil unless current_user&.contract_transactions&.count&.positive?
    { name: 'Watch List',
      path: watchlist_markets_path(list: :all),
      active: params[:action] == 'watchlist',
      icon: '&#xE8F4;' }
  end

  # rubocop:disable Metrics/MethodLength
  def nav_bottom_links
    [
      { name: 'How it Works',
        path: how_path,
        active: params[:action] == 'how',
        icon: '&#xE8FD;' },
      { name: 'Blog',
        path: blog_path,
        active: params[:action] == 'blog',
        icon: '&#xE0E5;' },
      { name: 'About us',
        path: about_path,
        active: params[:action] == 'about',
        icon: '&#xE88E;' }
    ]
  end

  def nav_category_link(cat)
    return nil unless cat.visible || current_admin_user
    { name: cat.name,
      path: browse_path(cat),
      active: cat == @market_category,
      offset: cat.depth > 1,
      icon: cat.material_icon }
  end

  def nav_link_to(*args, &block)
    name = block_given? ? capture(&block) : args.shift
    url = url_for(args.shift || {})
    html_options = args.shift || {}
    a = { class: 'mdc-list-item', class_active: 'mdc-list-item--activated' }
    active_link_to name, url, html_options.merge(a)
  end

  def nav_menu_to(*args, &block)
    name = block_given? ? capture(&block) : args.shift
    url = url_for(args.shift || {})
    html_options = args.shift || {}
    a = { class: 'mdc-list-item', role: 'option', tabindex: 0 }
    a['aria-selected'] = true if html_options[:active]
    link = link_to(name, url)
    content_tag('li', link, a)
  end

  def browse_path(category)
    if category.admin? || params[:controller] == 'admin/markets'
      raise "non-admin user" unless current_admin_user
      admin_market_category_path(category, category.url_name)
    else
      market_category_path(category, category.url_name)
    end
  end

  def browse_url(category)
    market_category_url(category, category.url_name)
  end
end
