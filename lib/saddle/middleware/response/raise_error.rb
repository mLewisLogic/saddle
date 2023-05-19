require 'faraday'


module Saddle
  module Middleware
    module Response
      class RaiseError < Faraday::Middleware

        def call(env)
          result = @app.call(env)

          case result.status
          when 404
            raise Faraday::ResourceNotFound, response_values(result)
          when 400...600
            raise Faraday::ClientError, response_values(result)
          end

          result
        end

        def response_values(result)
          {:status => result.status, :headers => result.headers, :body => result.body}
        end

      end
    end
  end
end
