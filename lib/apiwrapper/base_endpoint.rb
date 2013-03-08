require 'apiwrapper/util'

class BaseEndpoint

  def initialize(requester)
    @requester = requester
  end

  def get(action, params)
    @requester.get(path(action), params)
  end

  def post(action, params)
    @requester.post(path(action), params)
  end


  # Instance helper
  def path(action)
    self.class.path(action)
  end


  #
  ##
  ### Class methods

  def self.path(action)
    "/#{name_underscore}/#{action}"
  end

  def self.name_underscore
    underscore(to_s)
  end

end
