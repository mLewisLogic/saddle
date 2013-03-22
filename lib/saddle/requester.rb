require 'faraday'
require 'faraday_middleware'

require 'saddle/middleware/airbrake'
require 'saddle/middleware/default_response'
require 'saddle/middleware/parse_json'



class Requester

  VALID_BODY_STYLES = [:json, :urlencoded]

  # Available options
  ## host - host to connect to (default: localhost)
  ## port - port to connect on (default: 80)
  ## use_ssl - true if we should use https (default: false)
  ## post_style - :json or :urlencoded (default: :json)
  ## response_style - :json or :urlencoded (default: :json)
  ## num_retries - number of times to retry each request (default: 3)
  ## timeout - timeout in seconds
  ## additional_middleware - an Array of more middlewares to apply to the top of the stack
  ##                       - each middleware consists of hash of klass, and optionally args (an array)
  ## stubs - test stubs for specs
  def initialize(opt={})
    @host = opt[:host] || 'localhost'
    raise ':host must be a string' unless @host.is_a?(String)
    @port = opt[:port] || 80
    raise ':port must be an integer' unless @port.is_a?(Fixnum)
    @use_ssl = opt[:use_ssl] || false
    raise ':use_ssl must be true or false' unless (@use_ssl.is_a?(TrueClass) || @use_ssl.is_a?(FalseClass))
    @post_style = opt[:post_style] || :json
    raise ":post_style must be in: #{VALID_BODY_STYLES.join(',')}" unless VALID_BODY_STYLES.include?(@post_style)
    @response_style = opt[:response_style] || :json
    raise ":response_style must be in: #{VALID_BODY_STYLES.join(',')}" unless VALID_BODY_STYLES.include?(@response_style)
    @num_retries = opt[:num_retries] || 3
    raise ':num_retries must be an integer' unless @num_retries.is_a?(Fixnum)
    @timeout = opt[:timeout]
    unless @timeout.nil?
      raise ':timeout must be a number or nil' unless @timeout.is_a?(Numeric)
    end
    @additional_middleware = opt[:additional_middleware] || []
    raise ':additional_middleware must be an Array' unless @additional_middleware.is_a?(Array)
    raise 'invalid middleware found' unless @additional_middleware.all? { |m| m[:klass].is_a?(Faraday::Middleware) }
    raise 'middleware arguments must be an array' unless @additional_middleware.all? { |m| m[:args].nil? || m[:args].is_a?(Array) }
    @use_ssl = opt[:use_ssl] || false
    raise ':use_ssl must be true or false' unless (@use_ssl.is_a?(TrueClass) || @use_ssl.is_a?(FalseClass))
    @stubs = opt[:stubs] || nil
    unless @stubs.nil?
      raise ':stubs must be a Faraday::Adapter::Test::Stubs' unless @stubs.is_a?(Faraday::Adapter::Test::Stubs)
    end
  end


  # Make a GET request
  def get(url, params={}, options={})
    response = connection.get do |req|
      req.options.merge! options
      req.url url, params
    end
    response.body
  end

  # Handle request logic for PUT or POST
  def post_or_put(f, url, params={}, options={})
    response = connection.send(f) do |req|
      req.options.merge! options
      req.url url
      # Handle different supported post styles
      case @post_style
        when :json
          req.headers['Content-Type'] = 'application/json'
          req.body = params.to_json
        when :urlencoded
          req.params = params
        else
          raise RuntimeError(":post_style must be one of: #{VALID_POST_STYLES.join(',')}")
      end
    end
    response.body
  end

  # Make a POST request
  def post(url, params={}, options={})
    post_or_put(:post, url, params, options)
  end

  # Make a PUT request
  def put(url, params={}, options={})
    post_or_put(:put, url, params, options)
  end

  # Make a DELETE request
  def delete(url, params={}, options={})
    response = connection.delete do |req|
      req.options.merge! options
      req.url url, params
    end
    response.body
  end



  private

  # Construct a base url using this requester's settings
  def base_url
    "http#{'s' if @use_ssl}://#{@host}:#{@port}"
  end

  # Build a connection instance, wrapped in the middleware that we want
  def connection
    @connection ||= Faraday.new(base_url) do |builder|
      # Config options
      unless @timeout.nil?
        builder.options[:timeout] = @timeout
      end

      # Support default return values upon exception
      builder.use SaddleMiddleware::DefaultResponse

      # Apply additional implementation-specific middlewares
      @additional_middleware.each do |m|
        builder.use m[:klass], *m[:args]
      end

      # Support multi-part encoding if there is a file attached
      builder.request :multipart
      # Handle retries
      if @num_retries
        builder.request :retry, @num_retries
      end

      # Set up our adapter
      if @stubs.nil?
        # Use the default adapter
        builder.adapter :net_http
      else
        # Use the test adapter
        builder.adapter :test, @stubs
      end

      # Raise exceptions on 4xx and 5xx errors
      builder.response :raise_error
      # Handle parsing out the response if it's JSON
      builder.use SaddleMiddleware::ParseJson
    end
  end

end
