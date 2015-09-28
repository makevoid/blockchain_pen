extend UIHelpers

log "loading app.rb"

content = q ".content"

React.render(
  React.create_element(BCStylus),
  `content`
)

Stylus.write "antani come se fosse"
