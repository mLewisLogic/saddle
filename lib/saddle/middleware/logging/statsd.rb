require 'active_support/version'
if ActiveSupport::VERSION::STRING >= '7.1'
  require 'active_support/deprecation'
  require 'active_support/deprecator'
end
require 'active_support/core_ext/string'

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
          if env[:saddle][:statsd_path]
            statsd_path = env[:saddle][:statsd_path]
          elsif env[:saddle][:client]
            statsd_path_components = [
              'saddle',
              env[:saddle][:client].name.underscore,
            ]
            if env[:saddle][:call_chain] && env[:saddle][:action]
              statsd_path_components += env[:saddle][:call_chain]
              statsd_path_components << env[:saddle][:action]
            else
              statsd_path_components << 'raw'
              statsd_path_components << "#{env[:url].host}#{env[:url].path}"
            end
            statsd_path = statsd_path_components.join('.')
          end

          # If we have a path, wrap the call
          if statsd_path
            self.statsd.time(sanitize_path(statsd_path)) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end

        private
        def sanitize_path(path)
          path.gsub(/\s+/, '_').gsub(/\//, '-').gsub(/[^a-zA-Z_\-0-9\.]/, '')
        end
      end

    end
  end
end
