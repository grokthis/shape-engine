shape os.route.api.status {
  type: route
  method: GET
  path: /api/status
  handler: os.handler.api.status
  content_type: application/json
  layer: 4
  ""
}
