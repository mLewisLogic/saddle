require 'spec_helper'


describe Saddle::Client do

  context "POST requests" do
    context "using the default client" do

      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs)
      end

      it "should post empty" do
        @stubs.post('/test') {
          [
            200,
            {},
            'Party on!',
          ]
        }
        @default_client.requester.post('/test').should == 'Party on!'
      end

      it "should post url encoded" do
        @stubs.post('/test', 'a=0&b=true&c=Wingdings') {
          [
            200,
            {},
            'Party on!',
          ]
        }
        @default_client.requester.post(
          '/test',
          {'a' => 0, 'b' => true, 'c' => 'Wingdings'},
          {:request_style => :urlencoded}
        ).should == 'Party on!'
      end

      it "should post JSON encoded" do
        @stubs.post('/test', {'a' => 0, 'b' => true, 'c' => 'Wingdings'}.to_json) {
          [
            200,
            {},
            'Party on!',
          ]
        }
        @default_client.requester.post(
          '/test',
          {'a' => 0, 'b' => true, 'c' => 'Wingdings'},
          {:request_style => :json}
        ).should == 'Party on!'
      end

    end
  end
end
