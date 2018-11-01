class TradingSetsController < ApplicationController
  include My::SharesHistory

  before_action :market_init
  before_action :check_if_tradeable!, only: %i[new create]
  before_action :trading_set_form_init, only: %i[new create]
  before_action :current_user_objects_init, only: %i[new create]

  skip_before_action :authenticate_user!, only: %i[new]

  respond_to :html, :js

  def create
    if @form.save
      redirect_to my_trading_set_path(@form.market_shares_trx), notice: 'Your order is executed!'
    else
      render :new
    end
  end

  private

    def market_init
      @market = Market.findy(params[:market_id]) if params[:market_id]
    end

    def reset_trading_set
      redirect_to new_market_trading_set_path(@market, @form.default_outcome_params)
    end

    def trading_set_form_init
      @form = TradingSetForm.new(trading_set_form_params)
      reset_trading_set unless @form.valid_uri_params?
    end

    def trading_set_form_params
      uri_params = params.permit(TradingSetForm.uri_params_keys)
      form_params = params.fetch(:trading_set_form, {}).permit(TradingSetForm.form_attributes_keys)
      uri_params.merge(form_params).merge(user: current_user, market: @market)
    end

    # TODO: reuse the message from the trading orders
    def check_if_tradeable!
      return if @market.tradeable?
      msg = "Market is #{@market.state}."
      redirect_back fallback_location: market_path(@market), alert: msg
    end
end
