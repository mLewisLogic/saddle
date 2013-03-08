require 'apiwrapper/requester'


class ApiWrapper

  def initialize(opt={})
    @requester = Requester.new(opt)
    attach_endpoints
  end



  private

  def attach_endpoints
    self.class.endpoints.each do |endpoint|
      endpoint_instance = endpoint.new(@requester)
      self.instance_variable_set "@#{endpoint.name_underscore}", endpoint_instance
      self.class.class_eval { define_method(endpoint.name_underscore) { endpoint_instance } }
    end
  end

  ###
  # Specific endpoints are included by overloading this method
  # ie.
  #  require 'my_endpoint'
  #  def endpoints
  #    [MyEndpoint]
  #  end
  #
  ###
  def self.endpoints
    []
  end

end
