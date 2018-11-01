module Formatters
  module Ethereum
    def self.included(base)
      base.include ValidationMethods
      base.extend ValidationMethods
    end

    module ValidationMethods
      def valid_address?(address)
        ::Eth::Utils.valid_address?(address)
      end
    end
  end
end
