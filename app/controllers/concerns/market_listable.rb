module MarketListable
  extend ActiveSupport::Concern

  included do
    before_action :nav_categories_init
  end

  def index
    current_category_markets_init
  end

  def nav_categories_init
    categories = visible_category_roots.map { |n| MarketCategory.where(name: n).first }
    @nav_categories = categories.compact.map { |c| [c, c.children] }
  end

  def current_category_markets_init
    @market_category = MarketCategory.findy(params[:category_id]) if params[:category_id]
    @market_category ||= MarketCategory.where(name: 'Featured').first
    @markets = current_category_markets
  end

  def current_category_markets
    return [] unless @market_category
    if current_admin_user
      @market_category.self_and_descendants_markets.where(state: %w[pending published active])
    else
      @market_category.self_and_descendants_markets.active
    end
  end
end
