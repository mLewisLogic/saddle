require 'spec_helper'


describe 'FaradayMiddleware::Instrumentation' do

  context "test integration of instrumentation middleware" do

    it "with a request should not bomb" do
      client = Saddle::Client.create(
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
