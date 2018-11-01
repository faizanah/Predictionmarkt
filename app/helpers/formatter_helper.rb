require 'nokogiri'

module FormatterHelper
  include ActionView::Helpers::NumberHelper

  def sanitize_html(text, *args) # rubocop:disable Metrics/AbcSize
    return '' if text.blank?
    options = args.extract_options!
    options.reverse_merge!(autolink_length: 30)
    doc = options[:truncate] ? truncate(text, length: options[:truncate]) : text
    doc = options[:autolink] ? auto_link(doc) { |t| truncate(t, length: options[:autolink_length]) } : doc
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true), tables: true)
    doc = Nokogiri::HTML.fragment(sanitize(markdown.render(doc.strip)))
    doc.css('a').each { |l| l['rel'] = 'nofollow' }
    doc.to_html.html_safe
  end

  def nl2br(text)
    text.gsub(/(^|[^>])\r?\n/, '\1<br />')
  end

  def format_crypto_address(holder)
    return '&mdash;'.html_safe unless holder.ac.config[:external]
    address = holder.try(:address) || holder.try(:receiving_address) || raise
    link_to address, holder.ac.address_ext(address), target: '_blank'
  end

  def format_odds_direction(new_odds, old_odds)
    if new_odds && old_odds
      return 'up' if new_odds > old_odds
      return 'down' if new_odds < old_odds
    end
    nil
  end

  def format_odds_compare(new_odds, old_odds, args = {})
    direction = format_odds_direction(new_odds, old_odds)
    if args[:detailed] && direction
      format_odds(new_odds) + format_odds_change(new_odds - old_odds)
    else
      format_odds(new_odds, direction: direction)
    end
  end

  def normalize_odds(odds)
    return '&mdash;'.html_safe unless odds
    number_with_precision(odds * 100, precision: 2, strip_insignificant_zeros: true) + '%'
  end

  def format_odds(odds, args = {})
    classes = ['format-odds']
    if args[:direction]
      raise "wrong direction #{args[:direction]}" unless %w[up down].include?(args[:direction])
      classes << "format-odds-#{args[:direction]}"
    end
    txt = normalize_odds(odds)
    txt = args[:prefix] + txt if odds && args[:prefix]
    content_tag(:span, txt, class: classes)
  end

  def format_odds_change(odds)
    return nil if odds.zero?
    txt = number_with_precision(odds * 100, precision: 2, strip_insignificant_zeros: true)
    txt = "+" + txt if odds.positive?
    classes = ['format-odds-change', "format-odds-#{odds.positive? ? 'up' : 'down'}"]
    content_tag(:sup, txt, class: classes)
  end

  # trx could be a currency_transfer or a chainable transaction
  def format_reason(trx)
    content_tag('span', trx.reason.to_s.tr('_', ' '), class: 'trx-reason')
  end
end
