require 'faraday'
require 'simple_oauth'



module Saddle
  module Middleware
    module Authentication

      ## Add OAuth 1.0 authentication tokens to requests
      #
      class OAuth1 < Faraday::Middleware

        TYPE_URLENCODED = 'application/x-www-form-urlencoded'.freeze

        def call(env)
          if env[:saddle][:client_options][:oauth1] &&
             env[:saddle][:client_options][:oauth1][:consumer_key] &&
             env[:saddle][:client_options][:oauth1][:consumer_secret] &&
             env[:saddle][:client_options][:oauth1][:token] &&
             env[:saddle][:client_options][:oauth1][:token_secret]

            env[:request_headers]['Authorization'] ||= SimpleOAuth::Header.new(
              env[:method],
              env[:url].to_s,
              filtered_body_params(env),
              env[:saddle][:client_options][:oauth1]
            ).to_s
          end

          @app.call(env)
        end

        def body_params(env)
          # Only process body params if it's url-encoded or missing it's Content-Type
          # see RFC 5489, section 3.4.1.3.1 for details
          if !(type = env[:request_headers]['Content-Type']) or type == TYPE_URLENCODED
            if env[:body].respond_to?(:to_str)
              Faraday::Utils::parse_nested_query(env[:body])
            else
              env[:body]
            end
          end || {}
        end

        def filtered_body_params(env)
          body_params(env).reject {|k,v| v.respond_to?(:content_type) }
        end

      end

    end
  end
end
