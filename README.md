# apiwrapper

Makes writing API clients as easy as giving high fives.


## about
A generic Ruby API wrapper framework (for building service specific wrappers).

For an example of a concrete implementation, see [apiwrapper-example](https://github.com/mLewisLogic/apiwrapper-example)

## features
* set default connection settings for your implementation
* post urlencoded or JSON
* automatic retries and exception throwing

## guide
1. Inherit your endpoint from BaseEndpoint and call get or post from its methods
2. Inherit your client from ApiWrapper
3. Overload self.endpoints to include your endpoint

