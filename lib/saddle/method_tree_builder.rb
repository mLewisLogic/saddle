require 'active_support'

require 'saddle/base_endpoint'



module Saddle::MethodTreeBuilder

  # Build out the endpoint structure from the root of the implementation
  def build_tree(requester)
    root_node = build_root_node(requester)
    # If we have an 'endpoints' directory, build it out
    if Dir.exists?(endpoints_directory)
      Dir["#{endpoints_directory}/**/*.rb"].each { |f| load(f) }
      build_node_children(self.endpoints_module, root_node, requester)
    end
    root_node
  end

  # Build our root node here. The root node is special in that it lives below
  # the 'endpoints' directory, and so we need to manually check if it exists.
  def build_root_node(requester)
    root_endpoint_file = File.join(
      self.implementation_root,
      'root_endpoint.rb'
    )
    if File.file?(root_endpoint_file)
      # Load it and create our base endpoint
      load(root_endpoint_file)
      self.implementation_module::RootEndpoint.new(requester)
    else
      # 'root_endpoint.rb' doesn't exist, so create a dummy endpoint
      Saddle::BaseEndpoint.new(requester)
    end
  end

  # Build out the traversal tree by module namespace
  def build_node_children(current_module, current_node, requester)
    current_module.constants.each do |const_symbol|
      const = current_module.const_get(const_symbol)
      case const
        when Class
          # A class means that it's a node
          # Build out this endpoint on the current node
          self.build_and_attach_node(
            current_node,
            const,
            ActiveSupport::Inflector.underscore(const_symbol),
            requester
          )
        when Module
          # A module means that it's a branch
          # Build the branch out with a base endpoint
          branch_node = self.build_and_attach_node(
            current_node,
            Saddle::BaseEndpoint,
            ActiveSupport::Inflector.underscore(const_symbol),
            requester
          )
          # Build out the branch's endpoints on the new branch node
          self.build_node_children(const, branch_node, requester)
        else
      end
    end
  end


  # Create an instance and foist it upon this node
  def build_and_attach_node(current_node, endpoint_class, method_name, requester)
    endpoint_instance = endpoint_class.new(requester, method_name, current_node)
    current_node.instance_variable_set("@#{method_name}", endpoint_instance)
    current_node.class.class_eval { define_method(method_name) { endpoint_instance } }
    endpoint_instance
  end


  def implementation_module
    ::ActiveSupport::Inflector.constantize(
      self.name.split('::')[0..-2].join('::')
    )
  end

  def endpoints_module
    implementation_module.const_get('Endpoints')
  end

  # Get the path to the 'endpoints' directory, based upon the client
  # class that inherited Saddle
  def endpoints_directory
    File.join(self.implementation_root, 'endpoints')
  end

end
