shape os.route.api.deps {
  type: route
  method: GET
  path: /api/deps/{id...}
  handler: os.handler.api.deps
  content_type: application/json
  layer: 4
  ""
}
