module Attachable

  ### OVERRIDE THIS!
  #
  # Override this to include your endpoints
  # ex:
  #
  #  require 'my_endpoint'
  #  def self.endpoints
  #    [MyEndpoint]
  #  end
  #
  ###
  def endpoints
    []
  end


  # Initialize and attach each of the endpoints
  # Endpoints are accessed by their undercase name.
  # Ex. MyEndpoint would be accessed by client.my_endpoint
  def attach_endpoints
    endpoints.each do |endpoint|
      endpoint_instance = endpoint.new(@requester)
      instance_variable_set("@#{endpoint.name_underscore}", endpoint_instance)
      self.class.class_eval { define_method(endpoint.name_underscore) { endpoint_instance } }
    end
  end

end
