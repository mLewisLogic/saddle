# -*- encoding: utf-8 -*-

require 'saddle'

require '<%= project_name %>/exceptions'
require '<%= project_name %>/middleware/exception_raiser'
require '<%= project_name %>/stub'
require '<%= project_name %>/version'



module <%= root_module %>

  class Client < Saddle::Client
    extend <%= root_module %>::Stub


    # Place default client options here
    # Saddle supports many more options than are listed below. See the documentation.
    #def self.host
    #  'example.org'
    #end

    #def self.use_ssl
    #  true
    #end

    #def self.num_retries
    #  1
    #end

    #def self.timeout
    #  5 # seconds
    #end

    # Raise exceptions, based upon request responses
    add_middleware({
      :klass => Middleware::ExceptionRaiser,
    })

  end

end
