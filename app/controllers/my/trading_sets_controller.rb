class My::TradingSetsController < ApplicationController
  # TODO
  def show
    @market_shares_trx = current_user.market_shares_transactions.findy(params[:id])
    @market = @market_shares_trx.market
    @shares_transactions = current_user.spendable_shares.select { |trx| trx.market == @market }
  end
end
