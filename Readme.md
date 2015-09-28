# React.rb - Roda Websocket example

# mkv Opal setup (no sprockets, using guard)

A very fast opal setup - includes opal browser - uses guard to automatically compile your .js.ruby files as you save them - has opal and opal-browser vendored already in js files.

Open the project in a webserver:

    rake

or

    rackup



then open a browser at:

<http://localhost:3000>


#### Development

install the dependencies

    bundle


launch guard:

    guard


modify app.rb, save and refresh the browser


---

you can also run everything with a simple command (experimental)

    rake



- roda (routing tree framework)
- websocket plugin (uses faye)
- opal (write js in ruby)
- opal-browser (use websocket easily)
- react.rb (js dom diffing + cool ruby API to define views + state models)
