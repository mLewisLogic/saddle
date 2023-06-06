require 'faraday' # for test stubs
require 'saddle'

require 'pry'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end
