require 'faraday'
require 'saddle'



### Make sure that multiple implementations of Saddle clients don't conflict with each other's middlewar.

describe Saddle::Client do

  context "multiple implementations" do
    context "using different middleware" do

      before :each do
        # Middlewares
        class Middleware1 < Faraday::Middleware
          # Hook for catching calls
          def subcall
          end

          def call(env)
            self.subcall
            @app.call(env)
          end
        end

        class Middleware2 < Faraday::Middleware
          # Hook for catching calls
          def subcall
          end

          def call(env)
            self.subcall
            @app.call(env)
          end
        end


        # Clients
        class Client1 < Saddle::Client
          add_middleware({:klass => Middleware1})
        end
        class Client2 < Saddle::Client
          add_middleware({:klass => Middleware2})
        end
      end

      it "should not overlap" do
        # Set up our stubs
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/') {
            [
              200,
              {},
              'Party on!',
            ]
          }
        end

        # Set up our clients
        client1 = Client1.create(:stubs => stubs)
        client2 = Client2.create(:stubs => stubs)

        # Make sure client2's middleware isn't called
        Middleware1.any_instance.should_receive(:subcall)
        Middleware2.any_instance.should_not_receive(:subcall)

        # Make the call
        client1.requester.get('/')
      end

    end
  end
end
