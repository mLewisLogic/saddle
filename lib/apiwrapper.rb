require 'apiwrapper/attachable'
require 'apiwrapper/requester'


class ApiWrapper

  include Attachable

  # Options are passed down to the Requester.
  # See apiwrapper/requester.rb for available options.
  def initialize(opt={})
    opt = opt.merge({
      :additional_middleware => additional_middleware
    })
    @requester = Requester.new(
      default_options.merge(opt)
    )
    attach_endpoints
  end



  ### OVERRIDE THIS!
  #
  # Override this to add default initialize options to a concrete implementation
  # ex:
  #
  #  def self.default_options
  #    {
  #      :host => 'example.org',
  #      :port => 8080,
  #    }
  #  end
  #
  ###
  def default_options
    raise RuntimeError("self.default_options must be overridden.")
  end


  # See apiwrapper/attachable.rb for the actual implementation. This error just helps the noobs.
  def endpoints
    raise RuntimeError("self.endpoints must be overridden.")
  end


  ### OVERRIDE THIS IF YOU WANT!
  #
  # Override this to add additional middleware to the request stack
  # ex:
  #
  # require 'my_middleware'
  # def self.additional_middleware
  #   [MyMiddleware]
  # end
  #
  ###
  def additional_middleware
    []
  end

end
