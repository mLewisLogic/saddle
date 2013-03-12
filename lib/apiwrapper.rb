require 'apiwrapper/requester'


class ApiWrapper

  # Options are passed down to the Requester.
  # See apiwrapper/requester.rb for available options.
  def initialize(opt={})
    @requester = Requester.new(self.class.default_options.merge(opt))
    attach_endpoints
  end



  private

  ### OVERRIDE THIS!
  #
  # Override this to add default initialize options to a concrete implementation
  # ex:
  #
  #  def self.default_options
  #    {
  #      :host => 'example.org',
  #      :port => 8080,
  #    }
  #  end
  #
  ###
  def self.default_options
    raise RuntimeError("self.default_options must be overridden.")
  end


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
  def self.endpoints
    raise RuntimeError("self.endpoints must be overridden.")
  end



  # Initialize and attach each of the endpoints
  # Endpoints are accessed by their undercase name.
  # Ex. MyEndpoint would be accessed by client.my_endpoint
  def attach_endpoints
    self.class.endpoints.each do |endpoint|
      endpoint_instance = endpoint.new(@requester)
      self.instance_variable_set "@#{endpoint.name_underscore}", endpoint_instance
      self.class.class_eval { define_method(endpoint.name_underscore) { endpoint_instance } }
    end
  end

end
