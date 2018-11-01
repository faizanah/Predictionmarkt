module CurrencyConfig
  CONFIGS = Rails.application.config_for(:currencies)['application_currency'].with_indifferent_access.freeze

  def code
    @code ||= CONFIGS.find { |k, v| v['class'] == self.class.to_s }.first
  end

  def config
    @config ||= CONFIGS[code].with_indifferent_access
  end

  def logger
    @logger ||= Rails.logger
    # @logger ||= Logger.new(STDOUT)
  end

  def enabled?
    config['enabled']
  end

  def default?
    config['default']
  end

  def default
    find(&:default?)
  end

  def exchangeable?
    config['external']
  end

  def depositable?
    config[:enabled] && config[:external]
  end

  def withdrawable?
    config[:enabled] && config[:external]
  end

  def crypto?
    config['external']
  end

  # to seed the market on creation
  def seedable?
    config[:enabled] && config[:external]
  end
end
