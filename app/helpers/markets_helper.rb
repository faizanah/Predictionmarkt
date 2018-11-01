module MarketsHelper
  def market_rules(market)
    if market.market_spec
      render partial: "markets/rules/#{market.market_spec.class.name.demodulize.underscore}"
    else
      sanitize_html(market.rules)
    end
  end

  def market_image_path(market)
    cover_market_path(market, market.market_cover_img_name) if market.display_market_cover?
  end

  def market_image_url(market)
    cover_market_url(market, market.market_cover_img_name) if market.display_market_cover?
  end

  def market_publishing_operations(market)
    return unless @market_category&.parent&.name == 'Publishing'
    capture do
      if @market_category.name == 'Pending'
        concat update_market_state_link(market, 'active')
        concat update_market_state_link(market, 'ignored')
      elsif @market_category.name == 'Ignored'
        concat update_market_state_link(market, 'active')
      end
    end
  end

  def market_settling_operations(market)
    return unless @market_category&.parent&.name == 'Settling'
    capture do
      if @market_category.name == 'Pending'
        concat update_market_state_link(market, 'settled') if market.winner_outcome
      end
    end
  end

  def update_market_state_link(market, state)
    url = admin_market_path(market, market: { state: state })
    name = state.capitalize + '!'
    link_to name, url, class: 'market-action-btn',
                       method: :put,
                       data: { confirm: 'Sure?' }
  end

  def set_winner_outcome_link(market, outcome)
    return if market.winner_outcome
    url = admin_market_market_outcome_path(market, outcome, market_outcome: { winner: true })
    name = 'winner!'
    link_to name, url, class: 'market-action-btn', method: :put, data: { confirm: 'Sure?' }
  end

  def market_outcome_odds_range(outcome)
    odds_list = outcome.odds_range.map do |o|
      number_with_precision(o * 100, precision: 0, strip_insignificant_zeros: true)
    end
    odds_list.uniq!
    content_tag(:span, odds_list.join(' – ') + '%', class: 'format-odds')
  end

  def market_outcome_bar(outcome, args = {})
    basis = outcome.odds_avg * 50
    basis = basis < 2 ? '2px' : "#{basis}%"
    icon = case outcome.odds_dir
           when 'up' # trending up
             "&#xE8E5;"
           when 'down'
             "&#xE8E3;"
           end

    bar = capture do
      concat content_tag(:div, '', class: 'outcome__bar--inner', style: "flex-basis: #{basis}")
      label_text = capture do
        concat content_tag(:i, icon.html_safe, class: 'material-icons') if icon
        concat content_tag(:span, outcome.format_short_title)
      end
      concat content_tag(:div, label_text, class: 'outcome__bar--label')
      concat content_tag(:div, market_outcome_odds_range(outcome), class: 'outcome__bar--value')
    end
    classes = ['market-outcome-bar']
    classes << args[:class] if args[:class]
    content_tag(:div, class: classes) do
      content_tag(:div, bar, class: 'outcome__bar')
    end
  end
end
