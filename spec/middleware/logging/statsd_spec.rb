require 'spec_helper'

require 'saddle/middleware/logging/statsd'


describe Saddle::Middleware::Logging::StatsdLogger do

  context "test Statsd middleware" do

    it "with a request" do
      class StatsdClient < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Logging::StatsdLogger,
          :args => ['127.0.0.1'],
        })
      end

      client = StatsdClient.create(
        :stubs => Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/test') {
            [
              200,
              {},
              'Party on!',
            ]
          }
        end
      )
      client.requester.get('/test').should == 'Party on!'
    end

  end
end
