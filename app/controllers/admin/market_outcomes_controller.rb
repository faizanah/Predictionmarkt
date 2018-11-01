module Admin
  class MarketOutcomesController < Admin::BaseController
    before_action :market_outcome_init

    def create
      if @market_outcome.save
        redirect_to_market
      else
        render :edit
      end
    end

    def update
      if @market_outcome.update_attributes(market_outcome_params)
        redirect_to_market
      else
        render :edit
      end
    end

    #
    # Needs to handle foreign key constraints
    #
    # def destroy
    #   @market_outcome.destroy
    #   redirect_to_market
    # end

    private

      def redirect_to_market
        redirect_back fallback_location: edit_admin_market_path(@market)
      end

      def market_outcome_params
        params.fetch(:market_outcome, {}).permit(:title, :short_title, :ticker, :ticker_base, :odds, :winner)
      end

      def market_init
        @market = Market.findy(params[:market_id]) if params[:market_id]
        raise "need market id" unless @market
      end

      def market_outcome_init
        market_init
        @market_outcome = @market.market_outcomes.findy(params[:id]) if params[:id]
        @market_outcome ||= @market.market_outcomes.new(market_outcome_params)
      end
  end
end
