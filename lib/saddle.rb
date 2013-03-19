require 'saddle/method_tree_builder'
require 'saddle/requester'


class Saddle

  include MethodTreeBuilder

  attr_reader :requester

  # Options are passed down to the Requester.
  # See saddle/requester.rb for available options.
  def initialize(opt={})
    opt = opt.merge({
      :additional_middleware => additional_middleware
    })
    @requester = Requester.new(
      default_options.merge(opt)
    )
    attach_endpoint_tree
  end


  ### OVERRIDE THIS IF YOU WANT!
  #
  # Override this to add default initialize options to a concrete implementation
  #
  # Note: You must also override this if you want endpoint support
  #
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
    {}
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



  def self.inherited(obj)
    path, = caller[0].partition(":")
    @@implementation_root = File.dirname(path)
  end

  def self.implementation_root
    @@implementation_root
  end

end
