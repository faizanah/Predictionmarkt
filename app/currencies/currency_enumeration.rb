module CurrencyEnumeration
  include Enumerable

  def configs
    CurrencyConfig::CONFIGS
  end

  def get(c)
    c = Wallet.currencies.key(c) if c.is_a?(Integer)
    raise "unknown currency #{c.inspect}" unless configs[c]
    Object.const_get(configs[c]['class']).new
  end

  def each
    configs.each_key { |c| yield(get(c)) }
  end

  def each_with_code
    each { |ac| yield [ac, ac.code] }
  end

  def each_enabled
    select(&:enabled?).each do |ac|
      yield(ac)
    end
  end
end
