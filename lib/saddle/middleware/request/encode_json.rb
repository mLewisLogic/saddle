require 'faraday'



module Saddle::Middleware
  module Request

    # Request middleware that encodes the body as JSON.
    #
    # Make sure you set request[:request_style] = :json
    # for it to be activated.

    class JsonEncoded < Faraday::Middleware
      CONTENT_TYPE = 'Content-Type'.freeze
      MIME_TYPE    = 'application/json'.freeze

      dependency do
        require 'json' unless defined?(::JSON)
      end

      def call(env)
        if env[:request][:request_style] == :json
          # Make sure we're working with a valid body that's not a String
          if env[:body] and !env[:body].respond_to?(:to_str)
            env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
            env[:body] = ::JSON.dump(env[:body])
          end
        end
        @app.call env
      end
    end

  end
end