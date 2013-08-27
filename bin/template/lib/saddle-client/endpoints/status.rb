# -*- encoding: utf-8 -*-

require 'saddle/endpoint'

module <%= root_module %>
  module Endpoints

    class Status < Saddle::TraversalEndpoint

      ABSOLUTE_PATH = ''

      def healthy?
        get('health') == 'OK'
      end

    end

  end
end
