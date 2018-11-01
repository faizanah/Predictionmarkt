module TradingOrderFormMixins
  module Slider
    # Market orders

    def money_max
      user.balance(currency).fractional
    end

    def money_step
      contract.tick
    end

    def text_money
      Money.new(money, currency).amount
    end

    def text_money_step
      Money.new(contract.tick, currency).amount
    end

    # Market and limit orders

    def text_quantity
      quantity.to_i
    end

    def quantity_max
      ask? ? user&.shares(contract) : nil
    end

    # Limit

    def text_limit_price
      Money.new(limit_price, currency).amount
    end

    def text_limit_price_max
      Money.new(contract.max, currency).amount
    end

    def text_limit_price_step
      Money.new(contract.tick, currency).amount
    end

    def limit_price_step
      Money.new(contract.tick, currency).fractional
    end

    def limit_price_max
      contract.settle_price
    end

    def max_price_quantity
      { target: 'quantity',
        balance: user.balance(currency) }
    end
  end
end
