require 'spec_helper'

require 'saddle/middleware/logging/statsd'


describe Saddle::Middleware::Logging::StatsdLogger do

  context "test Statsd middleware" do

    class StatsdClient < Saddle::Client
      add_middleware({
        :klass => Saddle::Middleware::Logging::StatsdLogger,
        :args => ['127.0.0.1'],
      })
    end

    it "should log a request" do
      allow_any_instance_of(::Statsd).to receive(:time).with("saddle.statsd_client.raw.localhost-test").and_yield
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

    it "should allow overriding the path" do
      allow_any_instance_of(::Statsd).to receive(:time).with("hello").and_yield
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
      client.requester.get('/test', {}, {:statsd_path => "hello"}).should == 'Party on!'
    end

  end
end
