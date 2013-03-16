# apiwrapper

Hey nerd!


ApiWrapper makes writing service clients as easy as giving high fives.©™®℗☃✓

It's a full-featured generic consumer layer for you to build API client implementations on top of.


## about

Ok, I love high fives, but what does ApiWrapper do for me?

I'm glad you asked fellow nerd! Do you like automatic retries? Automatic multi-part file posting? I know I sure do!

Do you like sending your POSTs url-encoded? That's okay, I still love you anyways and ApiWrapper has your back. Does your rampant OCD refuse to let you post in anything less structured than JSON? High five nerd, ApiWrapper bleeds OCD. Just set your :post_style flag and fuhgedaboutit!

For an example of a concrete implementation, see [apiwrapper-example](https://github.com/mLewisLogic/apiwrapper-example)


## features
* set default connection settings for your implementation
* post urlencoded or JSON (xml soon)
* auto-parse JSON responses
* automatic retries and exception throwing


## guide
1. Inherit your endpoint from BaseEndpoint and call .get or .post within its action methods
2. Place those endpoints in the *endpoints* directory at the root of your client. Nest them if you like.
3. Inherit your client from ApiWrapper
4. Call client.endpoint.action()


## todo
* support xml post and parse
* support default return values upon error
