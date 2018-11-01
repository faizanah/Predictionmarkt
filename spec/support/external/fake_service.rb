require 'sinatra/base'

class FakeService < Sinatra::Base
  set :show_exceptions, true
  set :dump_errors, true

  protected

    def json_response(file_name)
      content_type :json
      status 200

      dirname = self.class.name.sub('Fake', '').downcase
      File.read("spec/fixtures/#{dirname}/#{file_name}")
    end

    def unknown_request
      raise "unknown request: #{request.query_string}"
    end
end
