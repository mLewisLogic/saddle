require 'faraday'
require 'faraday_middleware'


class Requester

  VALID_POST_STYLES = [:json, :urlencoded]

  # Available options
  ## host - host to connect to (default: localhost)
  ## port - port to connect on (default: 80)
  ## use_ssl - true if we should use https (default: false)
  ## post_style - :json or :urlencoded (default: :json)
  ## num_retries - number of times to retry each request (default: 3)
  ## timeout - timeout in seconds
  ## additional_middleware = an Array of more middlewares to apply to the top of the stack
  def initialize(opt={})
    @host = opt[:host] || 'localhost'
    raise RuntimeException(':host must be a string') unless @host.is_a?(String)
    @port = opt[:port] || 80
    raise RuntimeException(':port must be an integer') unless @port.is_a?(Fixnum)
    @use_ssl = opt[:use_ssl] || false
    raise RuntimeException(':use_ssl must be true or false') unless (@use_ssl.is_a?(TrueClass) || @use_ssl.is_a?(FalseClass))
    @post_style = opt[:post_style] || :json
    raise RuntimeException(":post_style must be in: #{VALID_POST_STYLES.join(',')}") unless VALID_POST_STYLES.include?(@post_style)
    @num_retries = opt[:num_retries] || 3
    raise RuntimeException(':num_retries must be an integer') unless @num_retries.is_a?(Fixnum)
    @timeout = opt[:timeout]
    unless @timeout.nil?
      raise RuntimeException(':timeout must be an integer or nil') unless @timeout.is_a?(Fixnum)
    end
    @additional_middleware = opt[:additional_middleware] || []
    raise RuntimeException(':additional_middleware must be an Array') unless @additional_middleware.is_a?(Array)
    raise RuntimeException('invalid middleware found') unless @additional_middleware.all? { |m| m.is_a?(Faraday::Middleware) }
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

      # Apply additional implementation-specific middlewares
      @additional_middleware.each do |m|
        builder.use m
      end

      # Support multi-part encoding if there is a file attached
      builder.request :multipart
      # Handle retries
      if @num_retries
        builder.request :retry, @num_retries
      end

      # Use the default adapter
      builder.adapter Faraday.default_adapter

      # Raise exceptions on 4xx and 5xx errors
      builder.response :raise_error
      # Parse out JSON responses if that's how it's coming back
      builder.response :json
    end
  end

end
