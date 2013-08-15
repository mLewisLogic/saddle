# 0.0.43
* Fixed a bug where non-string path elements were crashing

# 0.0.42
* Fixed a bug where nil actions resulted in a trailing /

# 0.0.41
* Cleanup of the path building chain makes nicer URLs

# 0.0.40
* Support for client-specified HTTP adapter. Preparing for Thrawn.

# 0.0.39
* DEPRECATION warning: root_endpoint.rb is no longer supported

# 0.0.38
* Support for `ABSOLUTE_PATH` on endpoints

# 0.0.37
* Lowered the default # of retries

# 0.0.36
* Parse JSON before throwing an error. The body may have useful failure info.
