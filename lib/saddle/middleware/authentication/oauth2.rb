require 'faraday'



module Saddle
  module Middleware
    module Authentication

      ## Add OAuth 2.0 authentication tokens to requests
      #
      class OAuth2 < Faraday::Middleware

        def initialize(app, key_name='access_token')
          super(app)
          @key_name = key_name
        end

        def call(env)
          if env[:request][:client_options][@key_name.to_sym]
            new_query = []
            new_query << env[:url].query if env[:url].query
            new_query << "#{@key_name}=#{CGI.escape(env[:request][:client_options][@key_name.to_sym].to_s)}"
            env[:url].query = new_query.join('&')
          end

          @app.call(env)
        end

      end

    end
  end
end
