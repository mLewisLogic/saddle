require 'faraday'



module Saddle
  module Middleware
    module Request

      # Public: Adds a prefix to the relative url path if present

      class PathPrefix < Faraday::Middleware
        def call(env)
          if env[:request][:client_options][:path_prefix]
            env[:url].path = "/#{env[:request][:client_options][:path_prefix]}#{env[:url].path}"
          end

          @app.call env
        end
      end

    end
  end
end
