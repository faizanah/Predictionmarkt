module ContractQuoteMixins
  module Udf
    include UdfHelper

    class Entity < Grape::Entity
      expose :s,             proc: proc { 'ok' }
      expose :n,             proc: proc { object.contract.ticker }

      expose :v do
        expose :short_name,  proc: proc { object.market_outcome.format_short_title }
        expose :description, proc: proc { object.market_outcome.title }
        expose :exchange,    proc: proc { object.market_outcome.ticker }

        expose :today_volume, as: :volume

        with_options(format_with: :percentage) do
          expose :ask,       proc: proc { object.ask&.odds }
          expose :bid,       proc: proc { object.bid&.odds }
          expose :lp,        proc: proc { object.last_trade&.odds }

          expose :today_high_odds,      as: :high_price
          expose :today_low_odds,       as: :low_price
          expose :today_open_odds,      as: :open_price
          expose :prev_close_odds,      as: :prev_close_price
          expose :today_change_odds,    as: :ch
        end

        expose :today_change_percent, as: :chp # TODO: add signature
      end

      private

        def prev_close_odds
          stat = object.contract.contract_trade_stats.daily.last
          return nil unless stat&.yesterday?
        end
    end

    class EntityCollection < Grape::Entity
      present_collection true
      expose :s, proc: proc { 'ok' }
      expose :items, as: 'd', using: Entity
    end
  end
end
