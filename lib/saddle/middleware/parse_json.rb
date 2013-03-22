require 'faraday_middleware/response_middleware'


module SaddleMiddleware
# Public: Parse response bodies as JSON.
  class ParseJson < FaradayMiddleware::ResponseMiddleware
    MIME_TYPE = 'application/json'.freeze

    dependency do
      require 'json' unless defined?(::JSON)
    end

    define_parser do |body|
      ::JSON.parse body unless body.strip.empty?
    end


    def parse_response?(env)
      type = response_type(env)
      super and has_body?(env) and (type.empty? or type == MIME_TYPE)
    end

    def has_body?(env)
      body = env[:body] and !(body.respond_to?(:to_str) and body.empty?)
    end

    def response_type(env)
      type = env[:response_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end

  end
end
