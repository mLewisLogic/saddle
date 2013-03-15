require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'


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
    @port = opt[:port] || 80
    @use_ssl = opt[:use_ssl]  || false
    @post_style = opt[:post_style] || :json
    @num_retries = opt[:num_retries] || 3
    @timeout = opt[:timeout]
    @additional_middleware = opt[:@additional_middleware] || []
  end


  # Make a GET request using this requester
  def get(url, params={}, options={})
    connection.get do |req|
      req.options.merge! options
      req.url url, params
    end.body
  end

  # Make a POST request using this requester
  def post(url, params={}, options={})
    connection.post do |req|
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
    end.body
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
      builder.options[:timeout] = @timeout unless @timeout.nil?

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

      # Make requests with Typhoeus
      builder.adapter :typhoeus

      # Raise exceptions on 4xx and 5xx errors
      builder.response :raise_error
      # Parse out JSON responses if that's how it's coming back
      builder.response :json
    end
  end

end
