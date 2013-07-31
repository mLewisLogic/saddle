require 'active_support/core_ext/string'



module Saddle

  # This base endpoint is what all implementation endpoints should inherit
  # from. It automatically provides tree construction and traversal
  # functionality. It also abstracts away url construction and requests to
  # the underlying requester instance.

  class BaseEndpoint

    attr_reader :requester, :relative_path, :parent

    # Each endpoint needs to have a requester in order to ... make ... uh ... requests.
    def initialize(requester, relative_path_override=nil, parent=nil)
      @requester = requester
      @parent = parent
      @relative_path = relative_path_override || _relative_path()
    end


    # Generic request wrapper
    def request(method, action, params={}, options={})
      # Augment in interesting options
      options[:saddle] ||= {}
      options[:saddle] = {
        :call_chain => _path_array(),
        :action => action,
      }
      @requester.send(method, _path(action), params, options)
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


    # This will create a resource endpoint, based upon the parameters
    # of this current node endpoint
    def create_resource_endpoint(endpoint_class, resource_id)
      endpoint_class.new(@requester, resource_id, self)
    end


    # Create an endpoint instance and foist it upon this node
    # Not private, but not part of the public interface for an endpoint
    def _build_and_attach_node(endpoint_class, method_name=nil)
      # Create the new endpoint
      endpoint_instance = endpoint_class.new(@requester, method_name, self)
      # Attach the endpoint as an instance variable and method
      method_name ||= endpoint_class.name.demodulize.underscore
      self.instance_variable_set("@#{method_name}", endpoint_instance)
      self.class.class_eval { define_method(method_name) { endpoint_instance } }
      endpoint_instance
    end


    protected

    # Get the url path for this endpoint/action combo
    def _path(action=nil)
      if defined?(self.class::ABSOLUTE_PATH)
        [self.class::ABSOLUTE_PATH, action].compact.join('/')
      else
        paths = _path_array()
        paths << action unless action.nil?
        paths.join('/')
      end
    end

    def _path_array
      _endpoint_chain().map(&:relative_path).reject{|p| p.nil?}
    end

    # Get the parent chain that led to this endpoint
    def _endpoint_chain
      chain = []
      node = self
      while node.is_a?(BaseEndpoint)
        chain << node
        node = node.parent
      end
      chain.reverse()
    end

    # If the parent is not an endpoint, it is a root node
    def _is_root?
      !@parent.is_a?(BaseEndpoint)
    end

    # Build the default relative path for this endpoint node
    #   If this is a root node, use nil.
    #   Otherwise use the underscored version of the class name
    #
    # Override this if needed for specific endpoints
    def _relative_path
      if _is_root?
        nil
      else
        self.class.name.demodulize.underscore
      end
    end
  end




  # This endpoint will be automatically constructed into the node
  # traversal tree.
  class TraversalEndpoint < BaseEndpoint; end


  # This endpoint is used for constructing resource-style endpoints. This
  # means it will NOT be automatically added into the traversal tree.
  class ResourceEndpoint < BaseEndpoint; end

end
