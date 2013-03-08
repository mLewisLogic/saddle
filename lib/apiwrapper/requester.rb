require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'


class Requester

  # Available options
  ## host - host to connect to (default: localhost)
  ## port - port to connect on (default: 80)
  ## use_ssl - true if we should use https
  def initialize(opt={})
    @host = opt[:host] || 'localhost'
    @port = opt[:port] || 80
    @use_ssl = opt[:use_ssl]  || false
    @post_json = opt[:post_json]  || false
    @num_retries = opt[:num_retries] || 3
  end

  def get(url, params)
    connection.get do |req|
      req.url url, params
    end.body
  end

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

  def base_url
    "http#{'s' if @use_ssl}://#{@host}:#{@port}"
  end

  def connection
    @connection ||= Faraday.new(base_url) do |builder|
      builder.request :multipart
      # Handle retries
      if @num_retries
        builder.request :retry, @num_retries
      end
      builder.response :raise_error
      builder.response :json
      # Make requests with Typhoeus
      builder.adapter :typhoeus
    end
  end

end
