module Admin
  class MarketsController < Admin::BaseController
    include MarketListable

    before_action :market_init
    before_action :market_outcome_init, only: %w[edit]

    def index
      super
      render 'markets/index'
    end

    def create
      if @market.save
        redirect_to edit_admin_market_path(@market)
      else
        render :new
      end
    end

    def update
      if @market.update_attributes(market_params)
        redirect_back fallback_location: edit_admin_market_path(@market), notice: "Market updated"
      else
        render :edit
      end
    end

    #
    # It needs to handle foreign constraints
    #
    # def destroy
    #   @market.destroy
    #   redirect_back fallback_location: admin_markets_path
    # end

    protected

      def visible_category_roots
        %w[Admin Generated Published]
      end

    private

      def market_init
        @market = params[:id] ? Market.findy(params[:id]) : current_user.markets.new(market_params)
      end

      def market_outcome_init
        @market_outcome = @market.market_outcomes.build
      end

      def market_params
        params.fetch(:market, {}).permit(:title, :lock_version,
                                         :ticker, :ticker_base,
                                         :rules, :close_date, :market_type, :state, :market_cover,
                                         market_category_ids: [])
      end
  end
end
