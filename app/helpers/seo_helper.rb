module SeoHelper
  def seo_friendly_str(str)
    str.titleize.tr(' /', '-').tr("%?.'\"", '')
  end

  def seo_market_path(market)
    titled_market_path(market, seo_friendly_str(market.title))
  end

  def seo_market_url(market)
    titled_market_url(market, seo_friendly_str(market.title))
  end

  def set_pmkt_meta_tags
    return unless request.get?
    set_market_meta_tags
    set_market_category_meta_tags
    set_default_meta_tags
    set_meta_tags title: @page_title,
                  description: @page_description,
                  keywords: @page_keywords,
                  fb: { app_id: Rails.application.config_for('creds-test')['facebook_app_id'] },
                  og: og_meta_tags
  end

  def set_default_meta_tags
    @page_keywords ||= "Prediction, Market, Trading, Ethereum"
    @page_title ||= "Prediction Markets Trading Platform"
    @page_description ||= "PredictionMarkt is a Ethereum-based trading platform for betting on the outcome of events in Business, Technology, Finance, Sports and Politics."
  end

  def set_market_meta_tags
    return unless @market&.persisted?
    @page_title ||= @market.title
    @page_description ||= [@market.title, @market_outcome&.format_short_title].compact.join(' ')
  end

  # TODO: check if it's a root page properly
  def set_market_category_meta_tags
    return unless @market_category && params[:category_id]
    @page_title ||= @market_category.name
  end

  def og_meta_tags
    og_tags = { site_name: :site }
    if @market&.persisted?
      og_tags.merge! market_og_tags
    elsif @post_config
      og_tags.merge! blog_og_tags
    elsif @market_category && params[:category_id]
      og_tags.merge! market_category_og_tags
    end
    og_tags
  end

  def market_og_tags
    { title: "PredictionMarkt | #{@market.title}",
      description: "Prediction Market in the Ethereum currency",
      type: 'pmkt:prediction_market',
      url: market_url(@market),
      image: market_image_url(@market) }
  end

  def blog_og_tags
    { title: @post_config[:title],
      type: 'article',
      url: blog_post_url_from_config(@post_config) }
  end

  def market_category_og_tags
    { title: "PredictionMarkt | #{@market_category.name}",
      description: "Prediction Markets in #{@market_category.name} category",
      type: 'pmkt:prediction_market_category',
      url: browse_url(@market_category) }
  end

  def pmkt_meta_tags
    set_pmkt_meta_tags
    display_meta_tags site: 'PredictionMarkt'
  end
end
