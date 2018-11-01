require 'feature_helper'

describe 'Markets' do
  let(:currency) { 'eth' }

  include_context 'trading time context'
  include_context 'predictit api'
  include_context 'trading context'

  # TODO: fix to support narrow viewports, selectbox is broken

  before do
    MarketCategory.seed
    PredictitRobot.new.ingest_markets
  end

  context 'index with active markets' do
    let(:user) { user_with_no_money }

    before do
      login_as(user)

      Market.all.each do |market|
        next if market.id.divmod(2).last == 0
        market.active!
      end
    end

    it "shows the list" do
      visit markets_path
      expect(page).to have_content(/Featured/i)
      snap('markets', 'ingested-list')
    end

    it 'shows the most predicted' do
      TradeGenerator.seed
      MarketCategory.update_generated
      visit markets_path
      click_on 'Most Predicted'
      snap('markets', 'most-predicted')
    end

    it 'shows the closing soon' do
      Market.active.sample(10).each do |m|
        m.update_attribute(:close_date, (rand(5) + 1).days.from_now)
      end
      MarketCategory.update_generated
      visit markets_path
      click_on 'Closing Soon'
      snap('markets', 'closing-soon')
    end

    it 'shows the biggest movers' do
      markets = Market.active.sample(10)
      seed_trades_prev_day(markets)
      MarketCategory.update_generated
      visit markets_path
      click_on 'Biggest Movers'
      snap('markets', 'biggest-movers')
    end

    it 'shows featured markets' do
      MarketCategory.update_generated
      visit markets_path
      click_on 'Featured'
      snap('markets', 'featured')
    end

    def seed_trades_prev_day(markets)
      travel_to(first_hour) { seed_trades(markets) }
      travel_to(second_hour) { ContractTradeStat.aggregate_hours }
      ContractTradeStat.aggregate_days
    end

    def seed_trades(markets)
      markets.each do |market|
        market.contracts.each do |contract|
          2.times { TradeGenerator.new(contract).perform }
        end
      end
      ContractTradeStat.aggregate_hours
    end
  end

  context 'showing markets' do
    let(:market) { contract.market }

    it 'shows market and its outcomes, empty' do
      login_as(user_with_no_money)
      visit market_path(market)
      snap('markets', 'show-empty')
    end

    it 'shows markets, some owned shares and open orders' do
      limit_ask(1, contract.tick * 200, user: user_with_money_and_shares)
      limit_bid(1, contract.tick * 100, user: user_with_money_and_shares)
      login_as(user_with_money_and_shares)
      visit market_path(market)
      snap('markets', 'show-owned')
      click_on 'History'
      snap('markets', 'show-history')
    end

    # it 'social buttons work' do
    #   login_as(user_with_no_money)
    #   visit market_path(market)
    #   %w[twitter facebook google+].each { |n| validate_social_link(n) }
    # end

    def validate_social_link(name)
      new_window = window_opened_by { click_on "Share on #{name.capitalize}" }
      within_window(new_window) do
        snap('markets', "show-#{name}")
        expect(page).to have_content(name.capitalize)
      end
    end
  end
end
