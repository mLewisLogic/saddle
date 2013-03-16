# Makes an underscored, lowercase form from the expression in the string.
#
# Changes '::' to '/' to convert namespaces to paths.
#
# Examples:
#   "ActiveModel".underscore         # => "active_model"
#   "ActiveModel::Errors".underscore # => "active_model/errors"
#
# As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
# though there are cases where that does not hold:
#
#   "SSLError".underscore.camelize # => "SslError"
#
### BLATANTLY RIPPED FROM RAILS SOURCE
def underscore(camel_cased_word)
  word = camel_cased_word.to_s.dup
  word.gsub!(/::/, '/')
  word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
  word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
  word.tr!("-", "_")
  word.downcase!
  word
end

# By default, +camelize+ converts strings to UpperCamelCase.
#
# +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
#
# Examples:
#   "active_model".camelize                # => "ActiveModel"
#   "active_model".camelize(:lower)        # => "activeModel"
#   "active_model/errors".camelize         # => "ActiveModel::Errors"
#   "active_model/errors".camelize(:lower) # => "activeModel::Errors"
#
# As a rule of thumb you can think of +camelize+ as the inverse of +underscore+,
# though there are cases where that does not hold:
#
#   "SSLError".underscore.camelize # => "SslError"
#
### BLATANTLY RIPPED FROM RAILS SOURCE
def camelize(underscored_word)
  string = underscored_word.to_s
  string = string.sub(/^[a-z\d]*/) { $&.capitalize }
  string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
end
