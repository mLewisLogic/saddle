require 'saddle/base_endpoint'
require 'saddle/util'


module MethodTreeBuilder

  def endpoint_root
    File.join(self.class.implementation_root, 'endpoints')
  end

  def attach_endpoint_tree
    if Dir.exists?(endpoint_root)
      attach_endpoint_directory(self, endpoint_root)
    end
  end

  def attach_endpoint_directory(node, directory)
    Dir.foreach(directory) do |entry|
      next if (entry == '..' || entry == '.')
      full_path = File.join(directory, entry)
      if File.directory?(full_path)
        # It's a directory. We're going to recurse down, but first we need to
        # create a branch node and build this directory onto it
        branch_node = build_and_attach_endpoint_to_node(node, entry, BaseEndpoint)
        attach_endpoint_directory(branch_node, full_path)
      else
        # It's an endpoint file, so load it
        require(full_path)
        without_extension = File.basename(entry, File.extname(entry))
        # Get the endpoint class based upon the filename
        class_name = camelize(without_extension) + 'Endpoint'
        endpoint = Object.const_get(class_name)
        # Now attach it to our method tree
        build_and_attach_endpoint_to_node(node, without_extension, endpoint)
      end
    end
  end

  # Create an instance and foist it upon this node
  def build_and_attach_endpoint_to_node(node, method_name, endpoint_class)
    endpoint_instance = endpoint_class.new(@requester, method_name, node)
    node.instance_variable_set("@#{method_name}", endpoint_instance)
    node.class.class_eval { define_method(method_name) { endpoint_instance } }
    endpoint_instance
  end

end
