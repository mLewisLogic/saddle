require 'active_support/core_ext/hash'
require 'active_support/notifications'

require 'faraday'
if Faraday::VERSION < '2'
  gem 'faraday_middleware'

  require 'faraday_middleware'
end
require 'saddle/faraday/request'
require 'saddle/faraday/rack_builder'

require 'saddle/middleware/request/encode_json'
require 'saddle/middleware/request/path_prefix'
require 'saddle/middleware/request/retry'
require 'saddle/middleware/request/url_encoded'
require 'saddle/middleware/request/user_agent'

require 'saddle/middleware/response/default_response'
require 'saddle/middleware/response/parse_json'
require 'saddle/middleware/response/raise_error'

require 'saddle/middleware/extra_env'
require 'saddle/middleware/ruby_timeout'



# The requester handles setting up the network connecting and brokering
# requests.


module Saddle
  class Requester

    VALID_BODY_STYLES = [:json, :urlencoded]

    # Available options
    ## host - host to connect to (default: localhost)
    ## port - port to connect on
    ## use_ssl - true if we should use https (default: false)
    ## request_style - :json or :urlencoded (default: :json)
    ## num_retries - number of times to retry each request (default: 3)
    ## timeout - timeout in seconds
    ## additional_middleware - an Array of more middlewares to apply to the top of the stack
    ##                       - each middleware consists of hash of klass, and optionally args (an array)
    ## stubs - test stubs for specs
    def initialize(parent_client, opt={})
      # We may want properties about the parent client in middlewares
      @parent_client = parent_client
      # Store the options for later use
      @options = opt
      @host = opt[:host] || 'localhost'
      raise ':host must be a string' unless @host.is_a?(String)
      @port = opt[:port]
      raise ':port must be nil or an integer' unless (@port.nil? || @port.is_a?(Integer))
      @use_ssl = opt[:use_ssl] || false
      raise ':use_ssl must be true or false' unless (@use_ssl.is_a?(TrueClass) || @use_ssl.is_a?(FalseClass))
      @request_style = opt[:request_style] || :json
      raise ":request_style must be in: #{VALID_BODY_STYLES.join(',')}" unless VALID_BODY_STYLES.include?(@request_style)
      @num_retries = opt[:num_retries] || 3
      raise ':num_retries must be an integer' unless @num_retries.is_a?(Integer)
      @timeout = opt[:timeout]
      raise ':timeout must be nil or an integer' unless (@timeout.nil? || @timeout.is_a?(Numeric))
      @extra_env = opt[:extra_env] || {}
      raise 'extra_env must be a Hash' unless @extra_env.is_a?(Hash)
      @additional_middlewares = opt[:additional_middlewares] || []
      raise ':additional_middleware must be an Array' unless @additional_middlewares.is_a?(Array)
      raise 'invalid middleware found' unless @additional_middlewares.all? { |m| m[:klass] < Faraday::Middleware }
      raise 'middleware arguments must be an array' unless @additional_middlewares.all? { |m| m[:args].nil? || m[:args].is_a?(Array) }

      @http_adapter = opt[:http_adapter] || :net_http
      raise ':http_adapter must be a symbol or a hash' unless @http_adapter.is_a?(Symbol) || @http_adapter.is_a?(Hash)
      @http_adapter = { :key => @http_adapter } if @http_adapter.is_a?(Symbol)
      raise 'adapter key must be a symbol' unless @http_adapter[:key].is_a?(Symbol)
      raise 'adapter arguments must be an array' unless @http_adapter[:args].nil? || @http_adapter[:args].is_a?(Array)

      @stubs = opt[:stubs] || nil
      unless @stubs.nil?
        raise ':stubs must be a Faraday::Adapter::Test::Stubs' unless @stubs.is_a?(Faraday::Adapter::Test::Stubs)
      end
      @return_full_response = opt[:return_full_response] || false
    end


    # Make a GET request
    def get(url, params={}, options={})
      response = connection.get do |req|
        req.saddle_options = options
        req.body = options[:body] if options.has_key?(:body)
        req.url(url, params)
      end
      handle_response(response)
    end

    # Make a POST request
    def post(url, data={}, options={})
      response = connection.post do |req|
        req.saddle_options = options
        req.url(url)
        req.body = data
      end
      handle_response(response)
    end

    # Make a PUT request
    def put(url, data={}, options={})
      response = connection.put do |req|
        req.saddle_options = options
        req.url(url)
        req.body = data
      end
      handle_response(response)
    end

    # Make a DELETE request
    def delete(url, params={}, options={})
      response = connection.delete do |req|
        req.saddle_options = options
        req.url(url, params)
      end
      handle_response(response)
    end



    private

    # Return the appropriate response format based on options
    def handle_response response
      @return_full_response ? response : response.body
    end

    # Construct a base url using this requester's settings
    def base_url
      "http#{'s' if @use_ssl}://#{@host}#{":#{@port}" if @port}"
    end

    # Build a connection instance, wrapped in the middleware that we want
    def connection
      @connection ||= Faraday.new(base_url, :builder_class => Saddle::RackBuilder) do |connection|
        # Include the requester level options
        connection.builder.saddle_options[:client_options] = @options

        # Config options
        connection.options[:timeout] = @timeout
        connection.builder.saddle_options[:request_style] = @request_style
        connection.builder.saddle_options[:num_retries] = @num_retries
        connection.builder.saddle_options[:client] = @parent_client

        # Support default return values upon exception
        connection.use(Saddle::Middleware::Response::DefaultResponse)

        # Hard timeout on the entire request
        connection.use(Saddle::Middleware::RubyTimeout)

        # Set up a user agent
        connection.use(Saddle::Middleware::Request::UserAgent)

        # Set up the path prefix if needed
        connection.use(Saddle::Middleware::Request::PathPrefix)

        # Apply additional implementation-specific middlewares
        @additional_middlewares.each do |m|
          m[:args] ? connection.use(m[:klass], *m[:args]) : connection.use(m[:klass])
        end

        # Request encoding
        connection.use(Saddle::Middleware::Request::JsonEncoded)
        connection.use(Saddle::Middleware::Request::UrlEncoded)

        # Automatic retries
        connection.use(Saddle::Middleware::Request::Retry)

        # Raise exceptions on 4xx and 5xx errors
        connection.use(Saddle::Middleware::Response::RaiseError)

        # Handle parsing out the response if it's JSON
        connection.use(Saddle::Middleware::Response::ParseJson)

        # Set up instrumentation around the adapter for extensibility
        connection.request :instrumentation

        # Add in extra env data if needed
        connection.use(Saddle::Middleware::ExtraEnv)

        # Set up our adapter
        if @stubs.nil?
          # Use the default adapter
          connection.adapter(@http_adapter[:key], *@http_adapter[:args])
        else
          # Use the test adapter
          connection.adapter(:test, @stubs)
        end
      end
    end

  end
end
