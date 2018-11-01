module My::SharesHistory
  extend ActiveSupport::Concern

  included do
  end

  protected

    # TODO: move this information into separate table in the databse
    # and run periodic tasks to update the aggregate information
    def order_chart
      @all_orders = @contract.trades.where('created_at > ?', 1.month.ago)
      @orders_chart = { }
      30.times do |i|
        timestamp = (i).days.ago.end_of_day
        # TODO shitty statistics, does not take into account the volume
        filtered_prices = @all_orders.reject { |e| e.created_at.end_of_day != timestamp}.map(&:price)
        @orders_chart[timestamp] = DescriptiveStatistics::Stats.new(filtered_prices)
      end
    end

    def contract_transactions(limit = 25)
      raise "no contract is set" unless @contract
      scope = current_user.contract_transactions.where(contract: @contract).where.not(total_change: 0).order('id desc')
      scope.page(params[:s_page]).per(limit)
    end

    def current_user_objects_init
      return unless current_user
      @trading_orders = trading_orders
      @historical_orders = historical_orders
      @shares_transactions = spendable_shares
    end

  private

    def trading_orders
      current_user.trading_orders.user_actionable.where(market: @market)
    end

    def historical_orders
      current_user.trading_orders.historical.where(market: @market).order('id desc').limit(10)
    end

    def spendable_shares
      current_user.spendable_shares.select { |trx| trx.market == @market }
    end
end
