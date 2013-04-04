


# Default options for a client. Override whatever you need to for
# your specific implementation


module Saddle::Options

  # Construct our default options, based upon the class methods
  def default_options
    {
      :host => host,
      :port => port,
      :use_ssl => use_ssl,
      :post_style => post_style,
      :response_style => response_style,
      :num_retries => num_retries,
      :timeout => timeout,
      :additional_middlewares => additional_middlewares,
      :stubs => stubs,
    }
  end

  # The default host for this client
  def host
    'localhost'
  end

  # The default port for this client
  def port
    80
  end

  # Should this client use SSL by default?
  def use_ssl
    false
  end

  # The POST/PUT style for this client
  # options are [:json, :urlencoded]
  def post_style
    :json
  end

  # How to parse results
  # options are [:json, :urlencoded]
  def response_style
    :json
  end

  # Default number of retries per request
  def num_retries
    3
  end

  # Default timeout per request (in seconds)
  def timeout
    30
  end

  # Override this to add additional middleware to the request stack
  # ex:
  #
  # require 'my_middleware'
  # def self.default_middleware
  #   [MyMiddleware]
  # end
  #
  ###
  def additional_middlewares
    []
  end

  # If the Typhoeus adapter is being used, pass stubs to it for testing.
  def stubs
    nil
  end

end
