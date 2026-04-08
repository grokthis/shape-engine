shape os.handler.api.deps {
  type: handler
  layer: 4
  """
let id = path_id
if id == "" {
  print("{\"error\":\"missing shape id\"}")
} else if !exists(id) {
  print("{\"error\":\"shape not found: " + id + "\"}")
} else {
  let dep_list = deps(id)
  let result = []
  set result = append(result, shape_to_map(id))
  for d in dep_list {
    if exists(d) {
      set result = append(result, shape_to_map(d))
    }
  }
  print(json_encode(result))
}
"""
}
