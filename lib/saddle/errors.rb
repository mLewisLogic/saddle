module Saddle
  # The parent class of all exceptions thrown by Saddle
  class Error < StandardError; end

  # Thrown when a request timeout is exceeded
  class TimeoutError < Error; end
end