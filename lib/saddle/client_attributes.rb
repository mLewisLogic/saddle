module Saddle::ClientAttributes

  def self.included(obj)
    obj.extend ClassMethods

    # Default values
    obj.additional_middlewares = []

    # We know that this module is included when saddle client is inherited,
    # so we're actually interested in the path of the caller two levels deep.
    path, = caller[2].partition(":")
    obj.implementation_root = File.dirname(path)
  end

  module ClassMethods
    attr_accessor :implementation_root
    attr_accessor :additional_middlewares
  end

end