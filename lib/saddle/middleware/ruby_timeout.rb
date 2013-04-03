require 'faraday'


module Saddle::Middleware

  # Public: Enforces a ruby timeout on the request
  # :timeout must be present in the request or client options
  class RubyTimeout < Faraday::Middleware

    def call(env)
      timeout = env[:request][:timeout] # nil or 0 means no timeout
      Timeout.timeout(timeout) do
        @app.call(env)
      end
    end

  end

end
