module Formatters
  module Bitcoin
    def self.included(base)
      base.include ValidationMethods
      base.extend ValidationMethods
    end

    module ValidationMethods
      def valid_address?(address)
        ::Bitcoin.valid_address?(address)
      end
    end
  end
end
