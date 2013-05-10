module Saddle::ClientAttributes

  def self.included(obj)
    obj.extend ClassMethods

    # Clone the parent's additional_middlewares
    obj.additional_middlewares = if defined?(obj.superclass.additional_middlewares)
      obj.superclass.additional_middlewares.clone
    else
      []
    end

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