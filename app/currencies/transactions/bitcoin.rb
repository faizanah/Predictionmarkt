require 'bitcoin'
require 'blockchain'

module Transactions
  module Bitcoin
    def self.included(base)
      base.include InstanceMethods
    end

    module InstanceMethods
      include ::Bitcoin::Builder

      # multiple full wallets => user address + residual + fee
      def generate_withdrawal_transaction(exported_order)
        tx = build_tx do |t|
          input_amount = generate_inputs(t, exported_order)
          validate_input_amount(input_amount, exported_order)
          generate_withdrawal_output(t, exported_order)
          generate_residual_output(t, input_amount, exported_order)
        end
        Base64.encode64(tx.to_payload)
      end

      def pushtx(raw_tx)
        tx = parsetx(raw_tx)
        tx_hex = Rails.env.production? ? tx.payload.unpack("H*")[0] : 'test'
        Blockchain::PushTx.new.pushtx(tx_hex)
      end

      def tx_hash(raw_tx)
        parsetx(raw_tx).hash
      end

      def tx_fee(inputs)
        s = inputs.size * 180 # ins
        s += 2 * 34 # 2 outs
        s += 10
        s * Services::Bitcoinfees.best_fee
      end

      def payload_to_raw_tx(tx_payload)
        Base64.encode64(tx_payload)
      end

      protected

        def parsetx(raw_tx)
          ::Bitcoin::P::Tx.new(Base64.decode64(raw_tx))
        end

        def generate_inputs(tx, exported_order)
          exported_order.from_addresses.reduce(0) do |input_amount, from_address|
            get_all_transactions(from_address).each do |b_tx|
              input_amount += b_tx.value
              tx.input do |i|
                i.prev_out(b_tx.tx_hash, b_tx.tx_output_n, [b_tx.script].pack("H*"))
                i.signature_key signing_key(from_address)
              end
            end
            input_amount
          end
        end

        def validate_input_amount(input_amount, exported_order)
          return if input_amount > exported_order.amount
          raise CurrencyError::NoFunds, "input amount #{input_amount} is lower than requested #{exported_order.amount}"
        end

        def generate_withdrawal_output(tx, exported_order)
          tx.output do |o|
            o.value exported_order.amount
            o.script { |s| s.recipient exported_order.to_address }
          end
        end

        # rubocop:disable Metrics/AbcSize
        def generate_residual_output(tx, input_amount, exported_order)
          fee = tx_fee(exported_order.from_addresses)
          logger.info { "Using #{fee} fee for transaction" }
          residual_amount = input_amount - exported_order.amount - fee
          # rubocop:disable Metrics/LineLength
          raise CurrencyError::NoFunds, "input #{input_amount} can't cover fee #{fee} and output #{exported_order.amount}" if residual_amount.negative?
          tx.output do |o|
            o.value residual_amount
            o.script { |s| s.recipient exported_order.residual_address }
          end
        end

        def explorer
          @explorer ||= Blockchain::BlockExplorer.new
        end

        # https://github.com/blockchain/api-v1-client-ruby/blob/master/docs/blockexplorer.md#unspentoutput-object
        def get_all_transactions(from_address)
          begin
            outputs = explorer.get_unspent_outputs([from_address])
          rescue Blockchain::Client::APIException => m
            Rails.logger.error("Blockchain API fail: #{from_address} / #{m.message}")
            outputs = []
          end
          raise "No unspent outputs for #{from_address}" if outputs.empty?
          outputs
        end
    end
  end
end
