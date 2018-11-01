class MarketsController < ApplicationController
  include MarketListable
  include My::SharesHistory
  include ReferralTrackable

  skip_before_action :authenticate_user!, only: %i[index show cover]
  before_action :find_viewable_market, only: %i[show cover]
  before_action :watchlist_markets_init, only: %i[watchlist]

  def watchlist
    render :index
  end

  def show
    @contracts = @market.contracts
    current_user_objects_init if current_user
  end

  def cover
    expires_in 30.days, public: true
    send_data(@market.market_cover_img_data, @market.market_cover_img_params.merge(disposition: 'inline'))
  end

  protected

    def visible_category_roots
      %w[Generated Published]
    end

  private

    def market_params
      params.fetch(:market, {})
    end

    def find_viewable_market
      @market = market_visible_scope.findy(params[:id])
      return if @market
      redirect_back fallback_location: markets_path, alert: 'Market not found'
    end

    def market_visible_scope
      current_admin_user ? Market : Market.user_viewable
    end

    def watchlist_markets_init
      case params[:list]
      when 'all'
        @markets = current_user.watched_markets
      when 'active'
        @markets = current_user.watched_markets_tradeable
      when 'closed'
        @markets = current_user.watched_markets_non_tradeable
      else
        redirect_back fallback_location: markets_path
      end
    end
end
