require 'faraday_middleware/response_middleware'


module SaddleMiddleware
  # Public: Returns a default response in the case of an exception
  # Expects default_response to be defined in the request of connection options, otherwise rethrows exception
  class DefaultResponse < Faraday::ResponseMiddleware

    def call(env)
      begin
        @app.call(env)
      rescue => e
        if res = env[:request][:default_response]
          return ::Faraday::Response.new(:body => res)
        else
          throw e
        end
      end
    end

  end
end
