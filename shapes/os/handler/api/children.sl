shape os.handler.api.children {
  type: handler
  layer: 4
  """
let id = path_id
if id == "" {
  print("{\"error\":\"missing shape id\"}")
} else {
  let kids = children(id)
  let result = []
  for k in kids {
    set result = append(result, shape_to_map(k))
  }
  print(json_encode(result))
}
"""
}
