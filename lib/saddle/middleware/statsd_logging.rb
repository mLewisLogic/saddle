require 'statsd'

module SaddleMiddleware
  # Public: Wraps request with statsd logging
  # Expects statsd_path in request options.  However, if using saddle and no statsd_path is specified
  # will read endpoint_chain and use as statsd_path
  class StatsdLogging < Faraday::Middleware
    attr_accessor :graphite_host, :graphite_port, :namespace

    def initialize(app, graphite_host, graphite_port=nil, namespace=nil)
      super(app)
      @graphite_host = graphite_host
      @graphite_port = graphite_port
      @namespace = namespace
      self.statsd
    end

    def statsd
      if(@statsd.nil?)
        @statsd = Statsd.new(@graphite_host, @graphite_port)
        @statsd.namespace = @namespace if @namespace
      end
      return @statsd
    end

    def call(env)
      statsd_path = env[:request][:statsd_path] || env[:request][:saddle][:endpoint_chain]
      if statsd_path && statsd_path.present?
        self.statsd.time statsd_path do
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end

  end
end