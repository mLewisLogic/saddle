require 'saddle'

describe Saddle::Client do

  context "instance" do
    before :each do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/test') {
          [
            200,
            {'Content-Type' => 'application/x-www-form-urlencoded'},
            'success'
          ]
        }
        stub.get('/test.json') {
          [
            200,
            {'Content-Type' => 'application/json'},
            {'success' => true}.to_json
          ]
        }
      end
      @client = Saddle::Client.create(:stubs => stubs)
    end

    it "should be able to request urlencoded" do
      @client.requester.get('/test').should == 'success'
    end

    it "should be able to request JSON encoded" do
      @client.requester.get('/test.json')['success'].should == true
    end
  end
end
