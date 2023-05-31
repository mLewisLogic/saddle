require 'spec_helper'

describe Saddle::Client do
  context "when path_prefix is set" do
    context "using the default client" do
      before :each do
        @stubs = Faraday::Adapter::Test::Stubs.new
        @default_client = Saddle::Client.create(:stubs => @stubs, :path_prefix => 'api/v1')
      end

      context "with no path" do
        context "for a GET request" do
          context "with no params" do
            it "should properly prefix the path" do
              url = ''
              @stubs.get('/api/v1/') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.get(url).should == 'Party!'
            end
          end

          context "with params" do
            it "should properly prefix the path" do
              url = '?a=1'
              @stubs.get('/api/v1/?a=1') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.get(url).should == 'Party!'
            end
          end
        end

        context "for a POST request" do
          context "with no params" do
            it "should properly prefix the path" do
              url = ''
              @stubs.post('/api/v1/') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.post(url).should == 'Party!'
            end
          end

          context "with params" do
            it "should properly prefix the path" do
              url = '?a=1'
              @stubs.post('/api/v1/?a=1') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.post(url).should == 'Party!'
            end
          end
        end
      end

      context "with a path" do
        context "for a GET request" do
          context "with no params" do
            it "should properly prefix the path" do
              url = '/test'
              @stubs.get('/api/v1/test') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.get(url).should == 'Party!'
            end
          end

          context "with params" do
            it "should properly prefix the path" do
              url = '/test?a=1'
              @stubs.get('/api/v1/test?a=1') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.get(url).should == 'Party!'
            end
          end
        end

        context "for a POST request" do
          context "with no params" do
            it "should properly prefix the path" do
              url = '/test'
              @stubs.post('/api/v1/test') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.post(url).should == 'Party!'
            end
          end

          context "with params" do
            it "should properly prefix the path" do
              url = '/test?a=1'
              @stubs.post('/api/v1/test?a=1') {
                [
                  200,
                  {},
                  'Party!',
                ]
              }
              @default_client.requester.post(url).should == 'Party!'
            end
          end
        end
      end
    end
  end
end
