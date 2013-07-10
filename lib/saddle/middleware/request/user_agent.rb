require 'faraday'



module Saddle
  module Middleware
    module Request

      # Public: Adds a user-agent to the request

      class UserAgent < Faraday::Middleware
        def call(env)
          # Build a user agent that looks like 'SaddleExample 0.0.1'
          user_agent = env[:request][:saddle][:client].name
          if env[:request][:saddle][:client].parent_module
            if defined?(env[:request][:saddle][:client].parent_module::VERSION)
              user_agent += " #{env[:request][:saddle][:client].parent_module::VERSION}"
            end
          end

          env[:request_headers]['User-Agent'] = user_agent

          @app.call env
        end
      end

    end
  end
end
