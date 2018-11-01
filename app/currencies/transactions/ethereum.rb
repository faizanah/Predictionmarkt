module Transactions
  module Ethereum
    def self.included(base)
      base.include InstanceMethods
    end

    module InstanceMethods
      # TODO: validate if input has more than output
      def generate_withdrawal_transaction(exported_order)
        validate_balances(exported_order)
        tx = Eth::Tx.new(data: '',
                         gas_limit: 21_000,
                         gas_price: Services::Etherscanio.gas_price,
                         nonce: 1,
                         to: exported_order.to_address,
                         value: exported_order.amount)
        tx.sign signing_key(exported_order.from_addresses.first)
        tx.hex
      end

      def pushtx(order)
        tx = parsetx(order.raw_transaction)
        Services::Etherscanio.pushtx(Rails.env.production? ? tx.hex : 'test')
      end

      def tx_hash(raw_tx)
        parsetx(raw_tx).hash
      end

      def tx_fee(_)
        21_000 * Services::Etherscanio.gas_price
      end

      def payload_to_raw_tx(tx_payload)
        tx_payload.strip
      end

      protected

        def parsetx(raw_tx)
          Eth::Tx.decode(raw_tx)
        end
    end
  end
end
