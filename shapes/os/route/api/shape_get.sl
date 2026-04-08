shape os.route.api.shape.get {
  type: route
  method: GET
  path: /api/shape/{id...}
  handler: os.handler.api.shape.get
  content_type: application/json
  layer: 4
  ""
}
