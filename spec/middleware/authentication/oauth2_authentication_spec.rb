require 'spec_helper'

require 'saddle/middleware/authentication/oauth2'


describe Saddle::Middleware::Authentication::OAuth2 do

  context "Test authentication middleware" do

    it 'should attach the oauth2 access token' do
      TEST_ACCESS_TOKEN = 'testes'

      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/test?oauth2_access_token=#{TEST_ACCESS_TOKEN}") {
          [
            200,
            {},
            'Party on!',
          ]
        }
      end

      class OAuth2Client < Saddle::Client
        add_middleware({
          :klass => Saddle::Middleware::Authentication::OAuth2,
          :args => ['oauth2_access_token'],
        })
      end

      client = OAuth2Client.create(
        :oauth2_access_token => TEST_ACCESS_TOKEN,
        :stubs => stubs
      )
      client.requester.get('/test').should == 'Party on!'
    end

  end
end
