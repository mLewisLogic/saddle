require 'saddle/client_attributes'
require 'saddle/method_tree_builder'
require 'saddle/options'
require 'saddle/requester'


# Inherit your client implementation from Saddle::Client
# then call YourCrayClient.create to get a client instance.


module Saddle

  class Client

    extend MethodTreeBuilder
    extend Options

    class << self
      attr_accessor :additional_middlewares
    end

    # Once your implementation is written, this is the magic you need to
    # create a client instance.
    def self.create(opt={})
      self.build_tree(
        Saddle::Requester.new(
          default_options.merge(opt)
        )
      )
    end

    def self.inherited(obj)
      # Clone the parent's additional_middlewares
      obj.additional_middlewares = if defined?(obj.superclass.additional_middlewares)
        (obj.superclass.additional_middlewares || []).clone
      else
        []
      end
      # Add additional client attributes
      obj.send(:include, Saddle::ClientAttributes)
    end    

  end

end
