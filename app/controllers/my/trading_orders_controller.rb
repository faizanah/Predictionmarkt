class My::TradingOrdersController < ApplicationController
  include My::SharesHistory
  before_action :init_trading_order, only: %i[show destroy]

  def index
    @trading_orders = current_user.trading_orders.maker.group_by(&:market)
    positions_scope = current_user.trading_orders.where.not(status: 'maker').order('id desc')
    @closed_positons = positions_scope.page(params[:closed_page]).per(10)
  end

  def show
    @market = @trading_order.market
    @market_outcome = @trading_order.market_outcome
    @contract = @trading_order.contract
  end

  def destroy
    # TODO: make sure funds are unescrowed, set flash message
    raise "something weird happened, trading order is not active maker order" unless @trading_order.maker?
    @trading_order.cancelled!
    redirect_back fallback_location: my_shares_path, notice: 'Order cancelled.'
  end

  private

    def init_trading_order
      @trading_order = current_user.trading_orders.findy(params[:id])
    end
end
