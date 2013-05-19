require 'saddle'



describe Saddle::Client do

  context "retry requests" do
    context "using the default client" do

      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs)
      end

      it "should retry properly with no params" do
        @stubs.get('/test') {
          [
            500,
            {},
            'Failure',
          ]
        }
        @stubs.get('/test') {
          [
            200,
            {},
            'Party!',
          ]
        }
        @default_client.requester.get('/test').should == 'Party!'
      end

      it "should retry properly when posting params urlencoded" do
        @stubs.post('/test', '{"a":"b","c":"d"}') {
          [
            500,
            {},
            'Failure',
          ]
        }
        @stubs.post('/test', '{"a":"b","c":"d"}') {
          [
            200,
            {},
            'Party!',
          ]
        }
        @default_client.requester.post(
          '/test',
          {'a' => 'b', 'c' => 'd'}
        ).should == 'Party!'
      end

    end
  end
end
