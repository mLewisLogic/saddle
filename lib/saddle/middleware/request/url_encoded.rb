require 'faraday'



module Saddle
  module Middleware
    module Request

      # This magically handles converting your body from a hash
      # into an url-encoded (or multipart if needed) request

      # Make sure you set request[:request_style] = :urlencoded
      # for it to be activated.

      class UrlEncoded < Faraday::Middleware
        CONTENT_TYPE = 'Content-Type'.freeze unless defined? CONTENT_TYPE

        URL_ENCODED_MIME_TYPE = 'application/x-www-form-urlencoded'.freeze
        MULTIPART_MIME_TYPE = 'multipart/form-data'.freeze

        VALID_MIME_TYPES = [URL_ENCODED_MIME_TYPE, MULTIPART_MIME_TYPE]

        DEFAULT_MULTIPART_BOUNDARY = "-^---_---^-".freeze


        def call(env)
          if env[:saddle][:request_style] == :urlencoded
            # Make sure we're working with a valid body that's not a String
            if env[:body] and !env[:body].respond_to?(:to_str)
              if has_multipart?(env[:body])
                env[:request][:boundary] ||= DEFAULT_MULTIPART_BOUNDARY
                env[:request_headers][CONTENT_TYPE] ||= MULTIPART_MIME_TYPE
                env[:request_headers][CONTENT_TYPE] += ";boundary=#{env[:request][:boundary]}"
                env[:body] = create_multipart(env, env[:body])
              else
                env[:request_headers][CONTENT_TYPE] ||= URL_ENCODED_MIME_TYPE
                env[:body] = Faraday::Utils::ParamsHash[env[:body]].to_query
              end
            end
          end
          @app.call env
        end


        private

        def has_multipart?(obj)
          # string is an enum in 1.8, returning list of itself
          if obj.respond_to?(:each) && !obj.is_a?(String)
            (obj.respond_to?(:values) ? obj.values : obj).each do |val|
              return true if (val.respond_to?(:content_type) || has_multipart?(val))
            end
          end
          false
        end

        def create_multipart(env, params)
          boundary = env[:request][:boundary]
          parts = process_params(params) do |key, value|
            Faraday::Parts::Part.new(boundary, key, value)
          end
          parts << Faraday::Parts::EpiloguePart.new(boundary)

          body = Faraday::CompositeReadIO.new(parts)
          env[:request_headers][Faraday::Env::ContentLength] = body.length.to_s
          body
        end

        def process_params(params, prefix = nil, pieces = nil, &block)
          params.inject(pieces || []) do |all, (key, value)|
            key = "#{prefix}[#{key}]" if prefix

            case value
              when Array
                values = value.inject([]) { |a,v| a << [nil, v] }
                process_params(values, key, all, &block)
              when Hash
                process_params(value, key, all, &block)
              else
                all << block.call(key, value)
            end
          end
        end
      end

    end
  end
end
