require 'rails_helper'

RSpec.describe ChartsApi do
  include Rack::Test::Methods
  def app
    ChartsApi::Udf
  end

  it 'returns time' do
    get '/charts/time'
    expect(last_response.status).to eq(200)
  end
end
