require 'spec_helper'


describe Saddle::Client do

  context "GET requests" do
    context "using the default client" do

      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs)
      end

      it "should request properly with params" do
        @stubs.get('/test?name=mike&party=true') {
          [
            200,
            {},
            'Party on!',
          ]
        }
        @default_client.requester.get(
          '/test',
          {'name' => 'mike', 'party' => true}
        ).should == 'Party on!'
      end

      it "should request properly with params in the body" do
        @stubs.send(:new_stub, :get, '/test', "body data") {
          [
            200,
            {},
            'Party on!',
          ]
        }
        @default_client.requester.get(
          '/test',
          {},
          {:body => 'body data'}
        ).should == 'Party on!'
      end

      it "should parse JSON encoded responses" do
        @stubs.get('/test.json') {
          [
            200,
            {'Content-Type' => 'application/json'},
            {'success' => true}.to_json,
          ]
        }
        @default_client.requester.get('/test.json')['success'].should == true
      end

    end
  end
end
