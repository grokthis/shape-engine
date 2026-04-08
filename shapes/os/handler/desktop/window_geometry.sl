shape os.handler.desktop.window.geometry {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let id = map_get(data, "id")
if id == "" {
  print("{\"error\":\"missing id\"}")
} else if !exists(id) {
  print("{\"error\":\"not found\"}")
} else {
  let l = map_get(data, "left")
  let t = map_get(data, "top")
  let w = map_get(data, "width")
  let h = map_get(data, "height")
  if l != "" {
    set_dim(id, "left", l)
  }
  if t != "" {
    set_dim(id, "top", t)
  }
  if w != "" {
    set_dim(id, "width", w)
  }
  if h != "" {
    set_dim(id, "height", h)
  }
  let mx = map_get(data, "maximized")
  if mx == "true" {
    set_dim(id, "maximized", "true")
  } else {
    set_dim(id, "maximized", "")
  }
  print("")
}
"""
}
