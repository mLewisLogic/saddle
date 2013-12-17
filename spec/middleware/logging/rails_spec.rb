require 'spec_helper'

require 'saddle/middleware/logging/rails'


describe Saddle::Middleware::Logging::RailsLogger do

  context "test Rails logging middleware" do

    it "with a request" do
      class RailsClient < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Logging::RailsLogger,
          :args => []
        })
      end

      client = RailsClient.create(
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
