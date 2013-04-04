



module Saddle

  # This base endpoint is what all implementation endpoints should inherit
  # from. It automatically provides tree construction and traversal
  # functionality. It also abstracts away url construction and requests to
  # the underlying requester instance.

  class BaseEndpoint

    attr_reader :requester, :relative_path, :parent

    # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
    def initialize(requester, relative_path=nil, parent=nil)
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
    def path(action=nil)
      paths = path_array
      paths << action unless action.nil?
      '/' + paths.join('/')
    end

    def path_array
      endpoint_chain.map(&:relative_path).reject{|p| p.nil?}
    end

    # Get the parent chain that led to this endpoint
    def endpoint_chain
      chain = []
      node = self
      until node.nil?
        chain << node
        node = node.parent
      end
      chain.reverse
    end


    # Create an endpoint instance and foist it upon this node
    def build_and_attach_node(endpoint_class, method_name)
      endpoint_instance = endpoint_class.new(@requester, method_name, self)
      self.instance_variable_set("@#{method_name}", endpoint_instance)
      self.class.class_eval { define_method(method_name) { endpoint_instance } }
      endpoint_instance
    end

    # This will create a resource endpoint, based upon the parameters
    # of this current node endpoint
    def create_resource_endpoint(endpoint_class, resource_id)
      endpoint_class.new(
        @requester,
        (path_array + [resource_id]).join('/')
        # no parent so that it can free up memory
      )
    end
  end




  # This endpoint will be automatically constructed into the node
  # traversal tree.
  class TraversalEndpoint < BaseEndpoint; end


  # This endpoint is used for constructing resource-style endpoints. This
  # means it will NOT be automatically added into the traversal tree.
  class ResourceEndpoint < BaseEndpoint; end

end
