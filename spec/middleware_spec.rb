require 'saddle'
require 'saddle/middleware/logging/airbrake'
require 'saddle/middleware/logging/statsd'

describe Saddle::Client do

  context "Test middlewares" do

    before :each do
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/test') {
          [
            200,
            {},
            'Party on!',
          ]
        }
      end

      @default_client = Saddle::Client.create(:stubs => @stubs)
    end


    it "test logging/airbrake" do
      class AirbrakeClient < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Logging::AirbrakeLogger,
        })
      end

      client = AirbrakeClient.create(:stubs => @stubs)
      client.requester.get('/test').should == 'Party on!'
    end

    it "test logging/statsd" do
      class StatsdClient < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Logging::StatsdLogger,
          :args => ['127.0.0.1'],
        })
      end

      client = StatsdClient.create(:stubs => @stubs)
      client.requester.get('/test').should == 'Party on!'
    end

  end
end
