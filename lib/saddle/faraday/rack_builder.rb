module Saddle
  # Same as the standard Faraday::RackBuilder, but also allows passing saddle options to the env.
  class RackBuilder < ::Faraday::RackBuilder
    def saddle_options
      @saddle_options ||= {}
    end

    def build_env(connection, request)
      env = super
      env[:saddle] = saddle_options.deep_merge(request.saddle_options)
      env
    end

  end
end
