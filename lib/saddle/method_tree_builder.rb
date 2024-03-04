require 'active_support/version'
if ActiveSupport::VERSION::STRING >= '7.1'
  require 'active_support/deprecation'
  require 'active_support/deprecator'
end
require 'active_support/core_ext/string'

require 'saddle/endpoint'



# This mixin provides functionality for the construction of the endpoint
# tree. It will start at the root directory and namespace of the client
# implementation. It will then load the 'endpoints' directory and
# build the endpoint tree based upon module/class namespaces


module Saddle
  module MethodTreeBuilder

    # Build out the endpoint structure from the root of the implementation
    def build_tree(requester)
      root_node = build_root_node(requester)
      # Search out the implementations directory structure for endpoints
      if defined?(self.implementation_root)
        # For each endpoints directory, recurse down it to load the modules
        endpoints_directories.each do |endpoints_directories|
          Dir["#{endpoints_directories}/**/*.rb"].each { |f| require(f) }
        end
        build_node_children(self.endpoints_module, root_node, requester)
      end
      root_node
    end


    # Build our root node here. The root node is special in that it lives below
    # the 'endpoints' directory, and so we need to manually check if it exists.
    def build_root_node(requester)
      if defined?(self.implementation_root)
        root_endpoint_file = File.join(
          self.implementation_root,
          'root_endpoint.rb'
        )
        if File.file?(root_endpoint_file)
          warn "[DEPRECATION] `root_endpoint.rb` is deprecated. Please use `ABSOLUTE_PATH` in your endpoints."
          # Load it and create our base endpoint
          require(root_endpoint_file)
          # RootEndpoint is the special class name for a root endpoint
          root_node_class = self.implementation_module::RootEndpoint
        else
          # 'root_endpoint.rb' doesn't exist, so create a dummy endpoint
          root_node_class = Saddle::RootEndpoint
        end
      else
        # we don't even have an implementation root, so create a dummy endpoint
        root_node_class = Saddle::RootEndpoint
      end
      root_node_class.new(requester, nil, self)
    end


    # Build out the traversal tree by module namespace
    def build_node_children(current_module, current_node, requester)
      return unless current_module
      current_module.constants.each do |const_symbol|
        const = current_module.const_get(const_symbol)

        if const.class == Module
          # A module means that it's a branch
          # Build the branch out with a base endpoint
          branch_node = current_node._build_and_attach_node(
            Saddle::TraversalEndpoint,
            const_symbol.to_s.underscore
          )
          # Build out the branch's endpoints on the new branch node
          self.build_node_children(const, branch_node, requester)
        end

        if const < Saddle::TraversalEndpoint
          # A class means that it's a node
          # Build out this endpoint on the current node
          current_node._build_and_attach_node(const)
        end
      end
    end


    # Get the module that the client implementation belongs to. This will act
    # as the root namespace for endpoint traversal and construction
    def implementation_module
      self.name.split('::')[0..-2].join('::').constantize
    end

    # Get all directories under the implementation root named 'endpoints'
    # This search allows for flexible structuring of gem
    def endpoints_directories
      Dir["#{implementation_root}/**/"].select { |d| d.ends_with?('endpoints/') }
    end

    # Get the Endpoints module that lives within this implementation's
    # namespace
    def endpoints_module
      begin
        implementation_module.const_get('Endpoints')
      rescue NameError
        nil # If there is no endpoints module, we just won't load any
      end
    end

  end
end
