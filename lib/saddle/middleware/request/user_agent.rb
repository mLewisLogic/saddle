require 'faraday'



module Saddle
  module Middleware
    module Request

      # Public: Adds a user-agent to the request

      class UserAgent < Faraday::Middleware
        def call(env)
          user_agent = nil
          # Build a user agent that looks like 'SaddleExample 0.0.1'
          begin
            user_agent = client_name = env[:request][:saddle][:client].name
            parent_module = client_name.split('::')[0..-2].join('::').constantize
            if parent_module
              if defined?(parent_module::VERSION)
                user_agent += " #{parent_module::VERSION}"
              end
            end
          rescue StandardError
          end
          env[:request_headers]['User-Agent'] = user_agent if user_agent

          @app.call env
        end
      end

    end
  end
end
