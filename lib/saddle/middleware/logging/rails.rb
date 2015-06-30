require 'faraday'



module Saddle
  module Middleware
    module Logging

      # Public: Log exceptions using the Rails logger
      #
      class RailsLogger < Faraday::Middleware

        def call(env)
          begin
            @app.call(env)
          rescue => e
            if defined?(Rails.logger)
              Rails.logger.error("#{env[:saddle][:saddle][:client].name} error: #{e}")
            end
            # Re-raise the error
            raise
          end
        end

      end
    end
  end
end
