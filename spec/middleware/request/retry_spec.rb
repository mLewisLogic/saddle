require 'faraday'
require 'saddle'



describe Saddle::Client do

  context "retry requests" do
    context "using the default client" do

      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs)
      end

      context "for a GET request" do
        it "with no params should properly retry" do
          url = '/test'
          @stubs.get(url) {
            [
              500,
              {},
              'Failure',
            ]
          }
          @stubs.get(url) {
            [
              200,
              {},
              'Party!',
            ]
          }
          @default_client.requester.get(url).should == 'Party!'
        end

        it "with params should properly retry" do
          url = '/test?a=1'
          @stubs.get(url) {
            [
              500,
              {},
              'Failure',
            ]
          }
          @stubs.get(url) {
            [
              200,
              {},
              'Party!',
            ]
          }
          @default_client.requester.get(url).should == 'Party!'
        end
      end



      context "for a POST request" do
        it "should not retry" do
          url = '/test'
          @stubs.post(url) {
            [
              500,
              {},
              'Failure',
            ]
          }
          @stubs.post(url) {
            [
              200,
              {},
              'Party!',
            ]
          }
          expect {
            @default_client.requester.post(url)
          }.to raise_error(Faraday::Error::ClientError)
        end

        it "should retry if it is marked as idempotent" do
          url = '/test'
          params = {'a' => 1, 'b' => 2}
          params_json = params.to_json
          @stubs.post(url, params_json) {
            [
              500,
              {},
              'Failure',
            ]
          }
          @stubs.post(url, params_json) {
            [
              200,
              {},
              'Party!',
            ]
          }
          @default_client.requester.post(
            url,
            params,
            {:idempotent => true}
          ).should == 'Party!'
        end
      end

    end
  end
end
