require 'saddle'



describe Saddle::Client do

  context "Default response requests" do

      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs)
      end

      it "should return as normal upon success" do
        @stubs.get('/test') {
          [
            200,
            {},
            'Party!',
          ]
        }
        @default_client.requester.get(
          '/test',
          {},
          {:default_response => 'Not a party.'}
        ).should == 'Party!'
      end

      it "should return the default response upon failure" do
        @stubs.get('/test') {
          [
            500,
            {},
            'Failure',
          ]
        }
        @default_client.requester.get(
          '/test',
          {},
          {:default_response => 'Not a party.'}
        ).should == 'Not a party.'
      end
  end
end
