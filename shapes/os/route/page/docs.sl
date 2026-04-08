shape os.route.page.docs {
  type: route
  method: GET
  path: /docs/{path...}
  handler: os.handler.page.docs
  content_type: text/html; charset=utf-8
  layer: 4
  ""
}
