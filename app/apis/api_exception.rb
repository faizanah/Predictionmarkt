class ApiException < StandardError
  attr_reader :http_status, :error

  def initialize(options)
    super

    if options.is_a?(HTTParty::Response)
      response = options
      options = { http_status: response.code, debug_info: response }
      options[:message] = response.body
    end
    options = options.with_indifferent_access
    @http_status = options[:http_status]

    @error = Error.new(code: options[:code], message: options[:message], debug_info: options[:debug_info])
  end

  class Error
    attr_reader :code, :message, :debug_info

    def initialize(*args)
      options = (args.first || {}).with_indifferent_access
      @code = options[:code]
      @message = options[:message]

      @debug_info = options[:debug_info] || ""
    end
  end
end
