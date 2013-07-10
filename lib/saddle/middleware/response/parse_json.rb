require 'faraday'



module Saddle
  module Middleware
    module Response

      # Public: Parse response bodies as JSON.
      class ParseJson < Faraday::Middleware

        CONTENT_TYPE = 'Content-Type'.freeze
        MIME_TYPE    = 'application/json'.freeze

        dependency do
          require 'json' unless defined?(::JSON)
        end

        def call(env)
          result = @app.call(env)

          if parse_response?(result)
            result.env[:body] = ::JSON.parse(result.env[:body])
          end
          result
        end


        private

        def parse_response?(result)
          has_body?(result) && (response_type(result) == MIME_TYPE)
        end

        def has_body?(result)
          result.env[:body] &&
            (!result.env[:body].respond_to?(:to_str) || # must already be in string format
             !result.env[:body].empty?) # or must be non-empty
        end

        def response_type(result)
          return nil unless result.headers
          type = result.headers[CONTENT_TYPE].to_s
          type = type.split(';', 2).first if type.index(';')
          type
        end

      end

    end
  end
end
