require 'airbrake'
require 'faraday'



module Saddle::Middleware
  module Logging

    # Public: Reports exceptions to Airbrake
    #
    class AirbrakeLogger < Faraday::Middleware

      def initialize(app, airbrake_api_key=nil)
        super(app)
        @airbrake_api_key = airbrake_api_key
      end

      def call(env)
        begin
          @app.call(env)
        rescue => e
          # If we don't have an api key, use the default config
          if @airbrake_api_key
            ::Airbrake.notify(e, {:api_key => @airbrake_api_key} )
          else
            ::Airbrake.notify(e)
          end
          # Re-raise the error
          raise
        end
      end

    end
  end
end
