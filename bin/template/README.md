# <%= service_name %> client


## Usage
```ruby
client = <%= root_module %>::Client.create()
service_status = client.status.healthy?
```


## Testing

### this project
* bundle exec rspec

### from an including project
In your spec_helper.rb, include the following snippet.
```ruby
<%= root_module %>::Client.stub!
```
This will prevent `<%= project_name %>` from reaching out to live servers.
Instead, endpoints will return back [local stubbed data](lib/<%= project_name %>/stub.rb).


## License
(c) <%= Time.now.year %>, <%= author_name %>
Released under the [MIT License](http://www.opensource.org/licenses/MIT).
