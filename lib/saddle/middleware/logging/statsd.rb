require 'statsd'
require 'faraday'




module Saddle
  module Middleware
    module Logging

      # Public: Wraps request with statsd logging
      # Expects statsd_path in request options.  However, if using saddle and no statsd_path is specified
      # will read call_chain and action and use them to construct a statsd_path
      class StatsdLogger < Faraday::Middleware
        attr_accessor :graphite_host, :graphite_port, :namespace

        def initialize(app, graphite_host, graphite_port=nil, namespace=nil)
          super(app)
          @graphite_host = graphite_host
          @graphite_port = graphite_port
          @namespace = namespace
        end

        def statsd
          @statsd ||= begin
            client = ::Statsd.new(@graphite_host, @graphite_port)
            client.namespace = @namespace if @namespace
            client
          end
        end

        def call(env)
          # Try to build up a path for the STATSD logging
          statsd_path = nil
          if env[:request][:statsd_path]
            statsd_path = env[:request][:statsd_path]
          elsif env[:request][:saddle]
            statsd_path = (
              ['saddle'] +
              env[:request][:saddle][:client_name] +
              env[:request][:saddle][:call_chain] +
              [env[:request][:saddle][:action]]
            ).join('.')
          end

          # If we have a path, wrap the ensuing app call in STATSD timing
          if statsd_path
            self.statsd.time(statsd_path) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end
      end

    end
  end
end
