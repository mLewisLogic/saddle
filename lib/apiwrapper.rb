require 'apiwrapper/requester'


class ApiWrapper

  def initialize(opt={})
    @requester = Requester.new(opt)
    attach_endpoints
  end



  private

  ###
  # Attach specific endpoints here
  # ie.
  #  require 'my_endpoint'
  #
  ###
  def attach_endpoints
    puts "You need to overload attach_endpoints"
  end

end
