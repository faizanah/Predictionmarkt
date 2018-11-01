# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_user = AdminUser.where(email: 'lex@rg.com').first
FactoryBot.create(:admin_user, email: 'lex@rg.com', password: 'lex@rg.com') unless admin_user

Remote::WalletCredentialsJob.perform_now

MarketCategory.seed

PredictitRobot.new.ingest_markets

FactoryBot.create(:market, title: 'binary market', market_type: 'binary')
cm = FactoryBot.create(:market, title: 'categorical market', market_type: 'categorical')
3.times { FactoryBot.create(:market_outcome, market: cm) }

Market.all.each do |market|
  next if market.id.divmod(2).last == 0
  market.active!
end

user = User.where(email: 'lex@realisticgroup.com').first
user ||= FactoryBot.create(:user, email: 'lex@realisticgroup.com',
                                  provider: 'google_oauth2', uid: '111724391071519685013',
                                  funds: [Money.from_amount(10, 'BTC'),
                                          Money.from_amount(15, 'ETH')],
                                  shares_with_market_cap: true,
                                  shares: { Contract.first => 15, Contract.last => 120 })

3.times do
  user.currency_transfers.deposit.finished.create!(total_change: 5000000, currency: 'eth', receiving_address: '0xb7B933bBaA026287d0dFBde712cc0Eb423411D3f')
end

2.times do
  user.currency_transfers.withdrawal.finished.create!(total_change: -1000, currency: 'eth', receiving_address: '0xb7B933bBaA026287d0dFBde712cc0Eb423411D3f')
  user.currency_transfers.withdrawal.pending.create!(total_change: -1000, currency: 'eth', receiving_address: '0xb7B933bBaA026287d0dFBde712cc0Eb423411D3f')
end

def seed_trades_day(markets, n = 10)
  n.times.reverse_each do |day|
    first_hour = day.day.ago.noon
    travel_to(first_hour)  { seed_trades(markets) }
    travel_to(first_hour + 1.hour) { seed_trades(markets) }
    travel_to(first_hour + 1.day) { ContractTradeStat.aggregate_days }
  end
end

def seed_trades(markets)
  markets.each do |market|
    market.contracts.each do |contract|
      2.times { TradeGenerator.new(contract).perform }
    end
  end
  ContractTradeStat.aggregate_hours
end

require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

seed_trades_day(Market.active.sample(10))

Contract.all.each { |c| TradeGenerator.new(c).perform }

MarketCategory.update_generated

# create filled orders
5.times do
  c = Contract.find(rand(1..Contract.last.id))
  bid_price = c.settle_price / 2 + c.tick
  ask_price = c.settle_price / 2 - c.tick

  user.deposit_shares_with_market_cap(c, 55)

  FactoryBot.create(:trading_order, :limit_ask, contract: c, user: user,
                                                requested_quantity: 4, limit_price: ask_price)
  FactoryBot.create(:trading_order, :limit_bid, contract: c,
                                                requested_quantity: 4, limit_price: bid_price)
end

# create half-filled filled ask orders
5.times do
  c = Contract.find(rand(1..Contract.last.id))
  bid_price = c.settle_price / 2 + c.tick
  ask_price = c.settle_price / 2 - c.tick

  user.deposit_shares_with_market_cap(c, 55)

  FactoryBot.create(:trading_order, :limit_ask, contract: c, user: user,
                                                requested_quantity: 10, limit_price: ask_price)
  FactoryBot.create(:trading_order, :limit_bid, contract: c,
                                                requested_quantity: 5, limit_price: bid_price)
end

# create half-filled bid orders
5.times do
  c = Contract.find(rand(1..Contract.last.id))
  bid_price = c.settle_price / 2 + c.tick
  ask_price = c.settle_price / 2 - c.tick

  FactoryBot.create(:trading_order, :limit_ask, contract: c, shares_with_market_cap: true,
                                                requested_quantity: 3, limit_price: ask_price)
  FactoryBot.create(:trading_order, :limit_bid, contract: c, user: user,
                                                requested_quantity: 6, limit_price: bid_price)
end

# Settle two markets
winner_trx = user.spendable_shares.first
loser_trx = user.spendable_shares.last

winner_trx.market_outcome.update_attribute(:winner, true)
winner_trx.market.settle!

winner_outcome = loser_trx.market.market_outcomes.select { |o| o.contracts.exclude?(loser_contract) }.first
winner_outcome.update_attribute(:winner, true)
winner_outcome.market.settle!
