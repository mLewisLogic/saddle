require 'faraday_middleware/response_middleware'


module SaddleMiddleware
  # Public: Reports exceptions to airbrake
  #
  class Airbrake < FaradayMiddleware::ResponseMiddleware

    def initialize(app, airbrake_api_key)
      super(app)
        ::Airbrake.configure do |config|
          config.api_key = airbrake_api_key
          # TODO: filter sensitive info
          # config.params_filters.concat(Security::SENSITIVE_PARAMS_STR)
        end
    end

    def call(env)
      begin
        @app.call(env)
      rescue => e
        ::Airbrake.notify(e)
        throw e
      end
    end

  end
end
