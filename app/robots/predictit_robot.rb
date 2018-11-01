class PredictitRobot < DataFeedRobot
  include Predictit::Selector

  def ingest_markets
    config[:selections].each do |name, selection|
      selection['groups'].each do |group_id, group_options|
        selector = selection.merge(group_options)
        predictit_markets = select_markets(group_id, selector)
        create_or_update_markets(predictit_markets, group_options)
      end
    end
  end

  private

    def create_or_update_markets(predictit_markets, group_options)
      predictit_markets.each do |predictit_market|
        predictit_market.ingest!
        assign_market_category(predictit_market.market, group_options)
      end
    end
end
