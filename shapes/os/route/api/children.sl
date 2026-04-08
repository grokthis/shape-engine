shape os.route.api.children {
  type: route
  method: GET
  path: /api/children/{id...}
  handler: os.handler.api.children
  content_type: application/json
  layer: 4
  ""
}
