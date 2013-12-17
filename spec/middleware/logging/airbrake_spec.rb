require 'spec_helper'

require 'saddle/middleware/logging/airbrake'


describe Saddle::Middleware::Logging::AirbrakeLogger do

  context "test Airbrake middleware" do

    it "with a request" do
      class AirbrakeClient < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Logging::AirbrakeLogger
        })
      end

      client = AirbrakeClient.create(
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
