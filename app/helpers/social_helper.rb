module SocialHelper
  def social_links_opts(args)
    url = args[:url] || url_for(r: current_user&.primary_referral_code&.code, only_path: false)
    title = args[:title] || @page_title || @market&.title || "PredictionMarkt"
    { url: url, title: title, desc: args[:desc] }
  end

  def social_links(args = {})
    default_opts = social_links_opts(args)
    content = capture do
      { twitter: {}, facebook: {}, google: { icon: 'google-plus-g', brand: 'Google+' } }.each do |name, opts|
        concat social_link_to(name, default_opts.merge(opts))
      end
    end
    content_tag(:div, content, class: 'sb')
  end

  def social_link_to(name, args = {})
    icon_tag = icon('fab', name, class: "sb__#{name}")
    sb_config = { sb: { target: name,
                        url: args[:url],
                        title: args[:title],
                        desc: args[:desc] } }
    link_to icon_tag, '#', class: 'sb__link',
                           data: sb_config,
                           rel: 'nofollow',
                           title: "Share on #{args[:brand] || name.capitalize}"
  end
end
