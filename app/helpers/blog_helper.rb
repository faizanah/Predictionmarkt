module BlogHelper
  class MarkdownRenderer < Redcarpet::Render::HTML
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::AssetTagHelper

    def link(link, title, content)
      link_to(content, link, title: title, rel: 'nofollow', target: '_blank', class: 'blog-link')
    end

    def image(link, title, alt_text)
      content_tag('a', image_tag(link, alt: alt_text || title, width: '100%'), href: link, class: 'md-zoomable-img')
    end
  end

  def blog_post_path_from_config(post_config)
    blog_post_path(post_config[:id], blog_post_uri(post_config))
  end

  def blog_post_url_from_config(post_config)
    blog_post_url(post_config[:id], blog_post_uri(post_config))
  end

  def blog_post_comment_url_from_config(post_config)
    blog_post_url(post_config[:id], 'post')
  end

  def blog_post_uri(post_config)
    post_config[:title].downcase.tr(' ', '-')
  end

  def blog_link_to(text, url)
    link_to(text, url, class: 'blog-link')
  end

  def blog_post_link_from_post_id(blog_post_id, args = {})
    post_config = @post_configs[blog_post_id]
    text = args[:text] || post_config[:title]
    css_class = args[:class] || 'btn-blog-action'
    link_to(text, blog_post_path_from_config(post_config), class: css_class)
  end
end
