require 'active_support'

require 'saddle/endpoint'



# This mixin provides functionality for the construction of the endpoint
# tree. It will start at the root directory and namespace of the client
# implementation. It will then load the 'endpoints' directory and
# build the endpoint tree based upon module/class namespaces


module Saddle::MethodTreeBuilder

  # Build out the endpoint structure from the root of the implementation
  def build_tree(requester)
    root_node = build_root_node(requester)
    # If we have an 'endpoints' directory, build it out
    if knows_root? && Dir.exists?(endpoints_directory)
      Dir["#{endpoints_directory}/**/*.rb"].each { |f| load(f) }
      build_node_children(self.endpoints_module, root_node, requester)
    end
    root_node
  end


  # Build our root node here. The root node is special in that it lives below
  # the 'endpoints' directory, and so we need to manually check if it exists.
  def build_root_node(requester)
    if knows_root?
      root_endpoint_file = File.join(
        @@implementation_root,
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
    else
      # we don't even have an implementation root, so create a dummy endpoint
      Saddle::BaseEndpoint.new(requester)
    end
  end


  # Build out the traversal tree by module namespace
  def build_node_children(current_module, current_node, requester)
    current_module.constants.each do |const_symbol|
      const = current_module.const_get(const_symbol)

      if const.class == Module
        # A module means that it's a branch
        # Build the branch out with a base endpoint
        branch_node = current_node.build_and_attach_node(
          Saddle::BaseEndpoint,
          ActiveSupport::Inflector.underscore(const_symbol)
        )
        # Build out the branch's endpoints on the new branch node
        self.build_node_children(const, branch_node, requester)
      end

      if const < Saddle::TraversalEndpoint
        # A class means that it's a node
        # Build out this endpoint on the current node
        current_node.build_and_attach_node(
          const,
          ActiveSupport::Inflector.underscore(const_symbol)
        )
      end
    end
  end


  # Get the module that the client implementation belongs to. This will act
  # as the root namespace for endpoint traversal and construction
  def implementation_module
    ::ActiveSupport::Inflector.constantize(
      self.name.split('::')[0..-2].join('::')
    )
  end

  # Get the Endpoints module that lives within this implementation's
  # namespace
  def endpoints_module
    implementation_module.const_get('Endpoints')
  end

  # Get the path to the 'endpoints' directory, based upon the client
  # class that inherited Saddle
  def endpoints_directory
    File.join(@@implementation_root, 'endpoints')
  end



  # When Saddle is inherited, we store the root of the implementation class
  # This is so that we know where to look for relative files, like
  # the endpoints directory
  def inherited(obj)
    path, = caller[0].partition(":")
    @@implementation_root = File.dirname(path)
  end

  # If this client was not fully constructed, it may not even have an
  # implementation root. Allow that behavior and avoid firesystem searching.
  def knows_root?
    defined?(@@implementation_root)
  end
end
