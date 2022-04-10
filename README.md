# purescript-cloudflare-workers

Purescript bindings for [cloudflare workers](https://developers.cloudflare.com/workers/). Feature incomplete as only basic functionality has been implemented.

## Tests
To run the integration test for the KV module
```
npm run test:kvserver       # Start the test server locally
npm run test:integration    # Then in another terminal run the tests
```

## Examples
This repository contains a [basic example](./examples/basic/src/Main.purs) for a server. Build and run it locally using `npm run example-basic:serve` from the root of the respository.
