# -*- encoding: utf-8 -*-

##
# Exceptions for using the <%= service_name %> client
# It is recommended that you handle these.
##

module <%= root_module %>

  class GenericException < StandardError; end

  class TimeoutError < GenericException; end

  # Some problems might take care of themselves if you try again later. Others won't.
  class TemporaryError < GenericException; end # fire warnings on these
  class PermanentError < GenericException; end # fire errors on these

  # Implement derivative exception classes here that represent specific errors that the
  # service can throw via status codes or response body

end
