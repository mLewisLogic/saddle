class BaseEndpoint

  def initialize(requester)
    @requester = requester
  end

  def get(action, params)
    @requester.get(path(action), params)
  end

  def post(action, params)
    @requester.post(path(action), params)
  end



  private

  def path(action)
    "/#{endpoint_prefix}/#{action}"
  end

  def endpoint_prefix
    self.class.to_s.underscore
  end

end
