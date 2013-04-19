require 'saddle/method_tree_builder'
require 'saddle/options'
require 'saddle/client_attributes'
require 'saddle/requester'



# Ghost ride the whip.
# Inherit your client implementation from Saddle::Client
# then call YourCrayClient.create to get a client instance.


module Saddle

  class Client

    extend MethodTreeBuilder
    extend Options

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
      obj.send(:include, Saddle::ClientAttributes)
    end    

  end

end
