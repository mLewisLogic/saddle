module Saddle::ImplementationRoot

  def self.included(obj)
    obj.extend ClassMethods

    # We know that this module is included when saddle client is inherited,
    # so we're actually interested in the path of the caller two levels deep.
    path, = caller[2].partition(":")
    obj.implementation_root = File.dirname(path)
  end

  module ClassMethods
    attr_accessor :implementation_root
  end

end