class TradingOrdersController < ApplicationController
  include My::SharesHistory
  before_action :market_outcome_init, only: %i[new create preview]
  before_action :trading_form_init, only: %i[new create preview]
  before_action :current_user_objects_init, only: %i[new create]

  skip_before_action :authenticate_user!, only: %i[new]

  respond_to :html, :js

  def create
    if @form.save
      msg = @form.order.active? ? 'The order has been created.' : 'The order has been created and closed immediately.'
      redirect_to my_trading_order_path(@form.order), notice: msg
    else
      render :new
    end
  end

  def preview
    @form.preview!
    render text: 'ok'
  end

  private

    # TODO: check when it's actually needed and split
    def market_outcome_init
      @market_outcome = MarketOutcome.findy(params[:market_outcome_id]) if params[:market_outcome_id]
      @market = @market_outcome.market
      check_if_tradeable!
      return unless @market_outcome
      @contract = @market_outcome.contracts.where(currency: params[:currency]).first
      @order_chart = order_chart if @contract
    end

    def check_if_tradeable!
      return unless @market
      return if @market_outcome.tradeable?
      # Market could be tradeable but contracts of this outcome could be non-active
      msg = @market.tradeable? ? 'Market is not tradeable.' : "Market is #{@market.state}."
      redirect_back fallback_location: markets_path, alert: msg
    end

    def reset_trading_order(**args)
      redirect_to new_market_outcome_trading_order_path(@market_outcome, @form.default_outcome_params), **args
    end

    def trading_form_init
      @form = TradingOrderForm.new(trading_order_form_params)
      reset_trading_order unless @form.valid_uri_params?
      @contract_quote = ContractQuote.new(@form.contract)
    end

    def trading_order_form_params
      uri_params = params.permit(TradingOrderForm.uri_params_keys)
      form_params = params.fetch(:trading_order_form, {}).permit(TradingOrderForm.form_attributes_keys)
      uri_params.merge(form_params).merge(user: current_user)
    end
end
