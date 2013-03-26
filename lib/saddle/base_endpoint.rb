require 'saddle/util'



class BaseEndpoint

  attr_reader :relative_path, :parent

  # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
  def initialize(requester, relative_path, parent=nil)
    @requester = requester
    @relative_path = relative_path
    @parent = parent.is_a?(BaseEndpoint) ? parent : nil
  end


  # Provide GET functionality for the implementer class
  def get(action, params={}, options={})
    request(:get, action, params, options)
  end

  # Provide POST functionality for the implementer class
  def post(action, params={}, options={})
    request(:post, action, params, options)
  end

  # Provide PUT functionality for the implementer class
  def put(action, params={}, options={})
    request(:put, action, params, options)
  end

  # Provide DELETE functionality for the implementer class
  def delete(action, params={}, options={})
    request(:delete, action, params, options)
  end

  def request(method, action, params={}, options={})
    # Augment in interesting options
    options[:saddle] = {
      :call_chain => path_array,
      :action => action,
    }
    @requester.send(method, path(action), params, options)
  end


  # Get the url path for this endpoint/action combo
  def path(action)
    '/' + (path_array + [action]).join('/')
  end

  def path_array
    endpoint_chain.map(&:relative_path)
  end

  # Get the parent chain that led to this endpoint
  def endpoint_chain
    chain = []
    node = self
    until node.nil?
      chain << node
      node = node.parent
    end
    chain
  end

end
