# Default options for a client. Override whatever you need to for
# your specific implementation

module Saddle
  module Options

    # Construct our default options, based upon the class methods
    def default_options
      {
        :host => host,
        :port => port,
        :path_prefix => path_prefix,
        :use_ssl => use_ssl,
        :request_style => request_style,
        :num_retries => num_retries,
        :timeout => timeout,
        :additional_middlewares => self.additional_middlewares,
        :stubs => stubs,
      }
    end

    # The default host for this client
    def host
      'localhost'
    end

    # The default port for this client
    def port
      nil
    end

    # A string prefix to prepend to paths as they are build (ie, 'v1')
    def path_prefix
      nil
    end

    # Should this client use SSL by default?
    def use_ssl
      false
    end

    # The POST/PUT style for this client
    # options are [:json, :urlencoded]
    def request_style
      :json
    end

    # Default number of retries per request
    def num_retries
      1
    end

    # Default timeout per request (in seconds)
    def timeout
      30
    end

    # If you want to set up an ActiveSupport::Notification, give your client
    #  an instrumentation key to monitor.
    def instrumentation_key
      nil
    end



    # Use this to add additional middleware to the request stack
    # ex:
    # add_middleware({
    #   :klass => MyMiddleware,
    #   :args => [arg1, arg2],
    # })
    # end
    #
    ###
    def add_middleware m
      self.additional_middlewares << m
    end

    # If the Typhoeus adapter is being used, pass stubs to it for testing.
    def stubs
      nil
    end

  end
end
