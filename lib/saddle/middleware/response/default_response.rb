require 'faraday'



module Saddle
  module Middleware
    module Response

      # Public: Returns a default response in the case of an exception
      # Expects default_response to be defined in the request of connection options, otherwise rethrows exception
      class DefaultResponse < Faraday::Middleware
        def call(env)
          begin
            @app.call(env)
          rescue
            if res = env[:saddle][:default_response]
              return ::Faraday::Response.new(:body => res)
            else
              raise
            end
          end
        end
      end

    end
  end
end
