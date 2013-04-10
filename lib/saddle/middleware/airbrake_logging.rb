require 'faraday'


module Saddle::Middleware

  # Public: Reports exceptions to airbrake
  #
  class AirbrakeLogging < Faraday::Middleware

    def initialize(app, airbrake_api_key)
      @airbrake_api_key = airbrake_api_key
      super(app)
    end

    def call(env)
      begin
        @app.call(env)
      rescue => e
        ::Airbrake.notify(
          e,
          {
            :api_key => @airbrake_api_key,
          }
        )
        raise
      end
    end

  end

end
