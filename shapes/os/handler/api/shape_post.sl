shape os.handler.api.shape.post {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let id = map_get(data, "id")
if id == "" {
  print("{\"error\":\"missing shape id\"}")
} else {
  let typ = map_get(data, "type")
  let c = map_get(data, "content")
  let d = map_get(data, "deps")
  if typ == "" {
    set typ = "shape"
  }
  if exists(id) {
    set_content(id, c)
    if typ != "" {
      set_dim(id, "type", typ)
    }
    print("{\"status\":\"updated\",\"shape\":\"" + id + "\"}")
  } else {
    if d != "" {
      add_shape(id, typ, c, d)
    } else {
      add_shape(id, typ, c)
    }
    print("{\"status\":\"created\",\"shape\":\"" + id + "\"}")
  }
}
"""
}
