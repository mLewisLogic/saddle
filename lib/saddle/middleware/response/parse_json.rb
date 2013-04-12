require 'faraday'



module Saddle::Middleware
  module Response

  # Public: Parse response bodies as JSON.
    class ParseJson < Faraday::Middleware
      CONTENT_TYPE = 'Content-Type'.freeze
      MIME_TYPE    = 'application/json'.freeze

      dependency do
        require 'json' unless defined?(::JSON)
      end

      def call(env)
        result = @app.call env
        if parse_response?(env)
          # Make sure we're working with a valid body that's not a String
          if env[:body] && env[:body].respond_to?(:to_str)
            env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
            env[:body] = ::JSON.parse env[:body]
          end
        end
        result
      end

      def parse_response?(env)
        has_body?(env) and (response_type(env) == MIME_TYPE)
      end

      def has_body?(env)
        body = env[:body] and !(body.respond_to?(:to_str) and body.empty?)
      end

      def response_type(env)
        return nil unless env[:response_headers]
        type = env[:response_headers][CONTENT_TYPE].to_s
        type = type.split(';', 2).first if type.index(';')
        type
      end
    end

  end
end
