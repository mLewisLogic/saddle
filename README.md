# saddle

Giddyup nerd! Wrangle your SOA.

Saddle makes writing service clients as easy as giving high fives. :hand:

It's a full-featured, generic consumer layer for you to build API client implementations with.


## about

Ok, I love high fives, but what does Saddle do for me?

Saddle is a framework that makes it exceptionally easy to write HTTP API clients. It abstracts away a lot of the repetitive work and lets you focus on your business logic. It also provides a simple middleware interface that makes it easy to extend functionality.

Saddle enables you to create beautifully stable and functionaly API clients, in the fewest lines of code possible.


## features

### client
* Specifying default connection settings for your client makes usage simple
* Automatic call tree construction, based upon module/class namespace
* Easily integrate with logging systems (currently supports statsd & Airbrake)
* Support simple testing of your client

### requests
* Post urlencoded or JSON (handles multipart file posts as well)
* Auto-parse JSON responses
* Strictly enforce request timeouts (client-wide or endpoint specific timeouts)

### error handling
* Automatic retries with exponential backoff
* Turns 4xx and 5xx responses into exceptions
* If desired, silently return default values upon exception


## guide

### concrete example
[saddle-example](https://github.com/mLewisLogic/saddle-example)

### client construction
0. For the sake of cleanliness, pick a namespace that everything related to your client should live in. For this example, we'll use __SaddleExample__.
1. Inherit your client class, __SaddleExample::Client__, from __Saddle::Client__.
2. Create an _endpoints_ directory at the same level as your client class file.
3. Create endpoint classes in the _endpoints_ directory that inherit from __Saddle::TraversalEndpoint__ and are under the __SaddleExample::Endpoints__ namespace module.
    1. Give these endpoints methods that call `get` or `post` to perform the actual request
    2. Their module/class namespace determines how they are accessed in the client's call tree. For example, the `get_all` in __SaddleExample::Endpoints::Fish::Guppy__ would be accessed by:

            client.fish.guppy.get_all

    3. If you need REST style endpoints like `client.kitten.by_id('Whiskers').info` then check out __Saddle::ResourceEndpoint__ and how it's used in [saddle-example](https://github.com/mLewisLogic/saddle-example/blob/master/lib/saddle-example/endpoints/kitten.rb)

4. Initialize an instance of your client. ex:

        saddle_example_client = SaddleExample::Client.create



## todo
* xml posting/parsing


## version notes

* Saddle versions 0.1.x are compatible with Faraday versions ~> 0.9.0
* Saddle versions 0.0.x are compatible with Faraday versions ~> 0.8.7

## Appraisal Usage

Appraisal is a gem that allows us to test our library against different versions of dependencies in repeatable scenarios called "appraisals". For more information see
the [Appraisal repository](https://github.com/thoughtbot/appraisal)

First make sure appraisal is installed by running

```
$ bundle install
```

To update the Appraisal's gemfiles run

```
$ bundle exec appraisal generate
```

To test against a specific version of `activesupport` first install the dependencies, ideally we would want to install them by running
```
$ bundle exec appraisal install
```

However, this isn't posible fot the different constraints these versions have. So instead install the dependencies for the desired version we want to test against by running

```
$ BUNDLE_GEMFILE=gemfiles/activesupport_6.0.gemfiles bundle install
```

In this example we want to install the dependencies of `activesupport` version `6.0`. Then to run `rspec` with that constraints we run

```
$ BUNDLE_GEMFILE=gemfiles/activesupport_6.0.gemfiles bundle exec rspec
```

## Code Status

* [![Build Status](https://travis-ci.org/mLewisLogic/saddle.png?branch=master)](https://travis-ci.org/mLewisLogic/saddle)
* [![Code Climate](https://codeclimate.com/github/mLewisLogic/saddle.png)](https://codeclimate.com/github/mLewisLogic/saddle)
* [![Dependency Status](https://gemnasium.com/mLewisLogic/saddle.png)](https://gemnasium.com/mLewisLogic/saddle)


## License

Saddle is released under the [MIT License](http://www.opensource.org/licenses/MIT).
