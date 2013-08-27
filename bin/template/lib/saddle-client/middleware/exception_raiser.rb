# -*- encoding: utf-8 -*-

require 'faraday'

require '<%= project_name %>/exceptions'



module <%= root_module %>
  module Middleware

    ## Raise beautiful exceptions
    #
    class ExceptionRaiser < Faraday::Middleware

      ## For handling errors, the message that gets returned is of the following format:
      # {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}

      def call(env)
        begin
          @app.call(env)
        rescue Faraday::Error::ClientError => e
          # This is our chance to reinterpret the response into a meaningful, client-specific
          # exception that a consuming service can handle
          exception = <%= root_module %>::GenericException

          raise exception, e.response
        rescue Saddle::TimeoutError => e
          raise <%= root_module %>::TimeoutError, e.response
        end
      end

    end

  end
end
