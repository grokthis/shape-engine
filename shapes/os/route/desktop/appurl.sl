shape os.route.desktop.appurl {
  type: route
  method: GET
  path: /desktop/appurl/{name}
  handler: os.handler.desktop.appurl
  content_type: application/json
  layer: 4
  ""
}
