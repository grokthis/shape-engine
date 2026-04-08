shape os.route.desktop.window.delete {
  type: route
  method: DELETE
  path: /desktop/window/{id...}
  handler: os.handler.desktop.window.delete
  content_type: application/json
  layer: 4
  ""
}
