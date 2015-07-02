# Allow saddle options to be accessible through Faraday::Request.
Faraday::Request.instance_eval do
  attr_accessor :saddle_options
end
