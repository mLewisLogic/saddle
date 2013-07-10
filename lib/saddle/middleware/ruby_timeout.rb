require 'faraday'

require 'saddle/errors'



module Saddle
  module Middleware

    # Public: Enforces a ruby timeout on the request and throws one consistent
    # exception for all classes of timeout, internal or from faraday.
    # :timeout must be present in the request or client options
    class RubyTimeout < Faraday::Middleware

      def call(env)
        timeout = env[:request][:hard_timeout] # nil or 0 means no timeout
        Timeout.timeout(timeout, Saddle::TimeoutError) do
          @app.call(env)
        end
      # It is possible that faraday will catch the timeout first and throw
      # this exception, rethrow as a class derived from standard error.
      rescue Faraday::Error::TimeoutError
        raise Saddle::TimeoutError
      end

    end

  end
end
