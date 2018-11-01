# Grape::Entity is extended in config/initializers/grape.rb
module UdfHelper
  include CurrencyFormatterHelper

  def odds_to_percentage(odds)
    (odds * 100).round(2) if odds
  end

  Grape::Entity.format_with :percentage do |odds|
    if odds&.is_a?(Array)
      odds.map { |o| odds_to_percentage(o) }
    elsif odds
      odds_to_percentage(o)
    end
  end

  Grape::Entity.format_with :secure_money_amount do |money|
    next unless money
    moneys = Array.wrap(money).map { |m| secure_rounded_money_pair(m, secure: true).last.amount }
    money.is_a?(Array) ? moneys : moneys.first
  end
end
