# BlockchainPen

BlockchainPen it's an UI and API for writing messages to the blockchain.

It is built using Ruby Opal and Bitcore.js

### Running it

Install the dependencies:

    bundle


Open the project in a webserver:

    rake

or

    rackup



then open a browser at:

<http://localhost:3000>


#### Development


launch guard:

    guard


when you modify a ruby file the dist/bundle.js file will be transpiled


---

you can also run everything with a simple command (experimental)

    rake



- roda (routing tree framework)
- websocket plugin (uses faye)
- opal (write js in ruby)
- opal-browser (use websocket easily)
- react.rb (js dom diffing + cool ruby API to define views + state models)

the old name was BlockchainPen, all the files in the repo named blockchain_stylus or bc_stylus are main files :)
