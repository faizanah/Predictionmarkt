module ChartsApi
  class Udf < Base
    resource :time do
      get do
        secure_time(Time.now).to_i
      end
    end

    resource :config do
      get do
        { supports_search: true,
          supports_group_request: false,
          supported_resolutions: %w[D],
          supports_marks: false,
          supports_time: true }
      end
    end

    resource :symbols do
      params do
        requires :symbol, type: String
      end
      get do
        contract = Contract.where(ticker: params[:symbol]).first
        Contract::UdfEntity.represent(contract)
      end
    end

    resource :history do
      params do
        requires :symbol,     type: String
        requires :from,       type: Integer
        requires :to,         type: Integer
        requires :resolution, type: String, values: %w[60 D]
      end
      get do
        contract = Contract.where(ticker: params[:symbol]).first
        from = Time.at(params[:from])
        to = Time.at(params[:to])
        ContractTradeStat::UdfHistory.represent ContractTradeStat.udf_history(contract, from, to, params[:resolution])
      end
    end

    # resource :quotes do
    #   params do
    #     requires :symbols, type: String
    #   end
    #   get do
    #     contracts = Contract.where(ticker: params[:symbols].split(','))
    #     present contracts.map { |c| ContractQuote.new(c) }, with: ContractQuote::EntityCollection
    #   end
    # end
  end
end
