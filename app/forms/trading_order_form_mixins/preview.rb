module TradingOrderFormMixins
  module Preview
    def preview!
      init_order
      @order.preview!
    end

    # limit orders only now
    def preview_initial_bid_volume
      Money.new(@order.filled_amount, currency)
    end

    def preview_quote
      return nil if @order.potential_trades.empty?
      @preview_quote ||= Trade.avg_quote(@order.potential_trades)
    end
  end
end
