shape os.handler.api.shape.get {
  type: handler
  layer: 4
  """
let id = path_id
if id == "" {
  print("{\"error\":\"missing shape id\"}")
} else if !exists(id) {
  print("{\"error\":\"shape not found: " + id + "\"}")
} else {
  let m = shape_to_map(id)
  print(json_encode(m))
}
"""
}
