require 'fileutils'
require 'money/bank/open_exchange_rates_bank'

class ExchangeRates
  def self.config
    @config ||= Rails.application.config_for(:currencies)
  end

  def self.oxr_app_id
    @app_id ||= if Rails.env.production?
                  Rails.application.credentials.openexchangerates_app_id
                else
                  Rails.application.config_for('creds-test')['openexchangerates_app_id']
                end
  end

  def self.bank_cache
    Rails.root.join('tmp/cache/openexchangerates.json').to_s
  end

  def self.initialize
    init_money
    init_app_currency # App currencies must be registered before the bank is initialized
    init_bank_rates
    init_app_currency_rates
  end

  def self.init_money
    Money.infinite_precision = true
    Money.default_formatting_rules = { drop_trailing_zeros: true }
  end

  def self.init_app_currency
    config['currencies'].each { |c| Money::Currency.register(c.symbolize_keys) }
  end

  def self.init_bank_rates
    oxr = Money::Bank::OpenExchangeRatesBank.new
    oxr.app_id = oxr_app_id + "&show_alternative=true"
    oxr.ttl_in_seconds = false
    oxr.source = 'USD'
    oxr.cache = bank_cache
    oxr.update_rates
    Money.default_bank = oxr
  end

  def self.init_app_currency_rates
    config['rates'].each do |from, to_many|
      to_many.each do |to, rate|
        Money.add_rate(from, to, rate)
        Money.add_rate(to, from, 1.0 / rate)
      end
    end
  end

  # It must be called only from the job
  # TODO: this update still requires a restart of the existing workers
  def self.update_rates
    new_cache = bank_cache + '.new'
    Money.default_bank.cache = new_cache
    Money.default_bank.update_rates
    Money.default_bank.save_rates
    raise "rates update failed" if File.size(new_cache) < 1000
    FileUtils.mv new_cache, bank_cache
    Money.default_bank.cache = bank_cache
  end
end
