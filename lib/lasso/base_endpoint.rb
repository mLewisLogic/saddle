require 'lasso/util'

class BaseEndpoint

  # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
  def initialize(requester)
    @requester = requester
  end


  # Provide 'get' functionality for the implementer class
  def get(action, params={}, options={})
    @requester.get(path(action), params, options)
  end

  # Provide 'get' functionality for the implementer class
  def post(action, params={}, options={})
    @requester.post(path(action), params, options)
  end


  # Get the url path for this endpoint/action combo
  def path(action)
    self.class.path(action)
  end
  def self.path(action)
    "/#{name_underscore}/#{action}"
  end


  # Get the url path of this endpoint, based upon it's class name
  def self.name_underscore
    underscore(to_s)
  end

end
