require 'saddle/util'

class BaseEndpoint

  # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
  def initialize(endpoint_root, requester)
    @endpoint_root = endpoint_root
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
    "/#{@endpoint_root}/#{action}"
  end

end
