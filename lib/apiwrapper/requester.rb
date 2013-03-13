require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'


class Requester

  # Available options
  ## host - host to connect to (default: localhost)
  ## port - port to connect on (default: 80)
  ## use_ssl - true if we should use https (default: false)
  ## post_json - true if POSTs should pass down a JSON-encoded body, otherwise it will be url-encoded (default: false)
  ## num_retries - number of times to retry each request (default: 3)
  ## timeout - timeout in ms
  def initialize(opt={})
    @host = opt[:host] || 'localhost'
    @port = opt[:port] || 80
    @use_ssl = opt[:use_ssl]  || false
    @post_json = opt[:post_json]  || false
    @num_retries = opt[:num_retries] || 3
    @timeout = opt[:timeout]
  end


  # Make a GET request using this requester
  def get(url, params)
    connection.get do |req|
      req.url url, params
    end.body
  end

  # Make a POST request using this requester
  def post(url, params)
    connection.post do |req|
      req.url url
      if @post_json
        req.headers['Content-Type'] = 'application/json'
        req.body = params.to_json
      else
        req.params = params
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
      builder.options[:timeout] = (@timeout / 1000.0) unless @timeout.nil?

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
