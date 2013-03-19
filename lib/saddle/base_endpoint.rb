require 'saddle/util'

class BaseEndpoint

  attr_reader :relative_path, :parent

  # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
  def initialize(requester, relative_path, parent=nil)
    @requester = requester
    @relative_path = relative_path
    @parent = parent.is_a?(BaseEndpoint) ? parent : nil
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
    '/' + (path_array + [action]).join('/')
  end

  def path_array
    parts = []
    node = self
    until node.nil?
      parts << node.relative_path
      node = node.parent
    end
    parts
  end

end
